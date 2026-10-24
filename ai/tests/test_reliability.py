"""Circuit breaker, request budget, and rate limit. No network."""

import asyncio

import pytest
from fastapi.testclient import TestClient

from app.ai.errors import AIServiceError
from app.ai.reliability import (
    CircuitBreaker,
    CircuitOpen,
    call_dependency,
    jev_breaker,
    llm_breaker,
)
from app.ai.schemas import ExtractionResult, Intent
from app.main import app


def _run(coro):
    return asyncio.run(coro)


class FakeClock:
    def __init__(self, start=1000.0):
        self.now = start

    def __call__(self):
        return self.now

    def advance(self, seconds):
        self.now += seconds


class FakeProvider:
    def __init__(self, outputs):
        self.outputs = list(outputs)
        self.calls = []

    async def complete(self, system, messages):
        self.calls.append((system, list(messages)))
        out = self.outputs.pop(0)
        if isinstance(out, Exception):
            raise out
        return out


class FakeJev:
    def __init__(self, error=None):
        self.error = error
        self.calls = 0

    async def classify(self, text, history=None):
        self.calls += 1
        raise self.error


def _ok_result():
    return ExtractionResult(
        intent=Intent.unknown,
        fields={},
        missing_fields=[],
        reply_text="ok",
    )


@pytest.fixture
def client():
    return TestClient(app)


def test_breaker_opens_rejects_and_closes_after_trial(monkeypatch):
    clock = FakeClock()
    monkeypatch.setattr("app.ai.reliability.clock", clock)
    monkeypatch.setenv("CIRCUIT_BREAKER_FAILURES", "2")
    monkeypatch.setenv("CIRCUIT_BREAKER_COOLDOWN_SECONDS", "30")
    breaker = CircuitBreaker("test")
    calls = {"n": 0}

    async def fail():
        calls["n"] += 1
        raise AIServiceError("down")

    async def ok():
        calls["n"] += 1
        return "ok"

    with pytest.raises(AIServiceError):
        _run(call_dependency(breaker, fail))
    with pytest.raises(AIServiceError):
        _run(call_dependency(breaker, fail))
    assert calls["n"] == 2

    with pytest.raises(CircuitOpen):
        _run(call_dependency(breaker, ok))
    assert calls["n"] == 2

    clock.advance(29)
    with pytest.raises(CircuitOpen):
        _run(call_dependency(breaker, ok))
    assert calls["n"] == 2

    clock.advance(1)
    assert _run(call_dependency(breaker, ok)) == "ok"
    assert calls["n"] == 3
    # Closed: one failure does not open again, so the next call still runs.
    with pytest.raises(AIServiceError):
        _run(call_dependency(breaker, fail))
    assert _run(call_dependency(breaker, ok)) == "ok"
    assert calls["n"] == 5


def test_failed_trial_stays_open(monkeypatch):
    clock = FakeClock()
    monkeypatch.setattr("app.ai.reliability.clock", clock)
    monkeypatch.setenv("CIRCUIT_BREAKER_FAILURES", "1")
    monkeypatch.setenv("CIRCUIT_BREAKER_COOLDOWN_SECONDS", "30")
    breaker = CircuitBreaker("trial")
    calls = {"n": 0}

    async def fail():
        calls["n"] += 1
        raise TimeoutError("slow")

    with pytest.raises(TimeoutError):
        _run(call_dependency(breaker, fail))
    clock.advance(30)
    with pytest.raises(TimeoutError):
        _run(call_dependency(breaker, fail))
    with pytest.raises(CircuitOpen):
        _run(call_dependency(breaker, fail))
    assert calls["n"] == 2


def test_open_jev_breaker_falls_back_without_calling_jev(monkeypatch):
    monkeypatch.setenv("CLASSIFIER_PROVIDER", "jev")
    monkeypatch.setenv("CIRCUIT_BREAKER_FAILURES", "1")
    monkeypatch.setenv("CIRCUIT_BREAKER_COOLDOWN_SECONDS", "60")

    async def down():
        raise AIServiceError("down")

    with pytest.raises(AIServiceError):
        _run(call_dependency(jev_breaker(), down))

    fake = FakeJev(error=AIServiceError("should not be called"))
    monkeypatch.setattr("app.ai.router._get_jev", lambda: fake)
    provider = FakeProvider(['{"intent": "app_help"}'])

    from app.ai.parser import parse_request

    result = _run(parse_request("hello", provider=provider))
    assert fake.calls == 0
    assert result.fallback_used is True
    assert result.classifier == "gemini"
    assert result.intent is Intent.app_help
    assert len(provider.calls) == 1


def test_llm_breaker_open_is_503_without_calling_provider(monkeypatch, client):
    monkeypatch.setenv("LLM_PROVIDER", "gemini_native")
    monkeypatch.setenv("CIRCUIT_BREAKER_FAILURES", "1")
    monkeypatch.setenv("CIRCUIT_BREAKER_COOLDOWN_SECONDS", "60")

    async def down():
        raise AIServiceError("down")

    with pytest.raises(AIServiceError):
        _run(call_dependency(llm_breaker(), down))

    provider = FakeProvider(['{"intent": "app_help"}'])
    monkeypatch.setattr("app.ai.get_provider", lambda: provider)
    response = client.post(
        "/parse",
        json={"text": "hi"},
        headers={"X-User-Id": "llm-open"},
    )
    assert response.status_code == 503
    assert response.json() == {"error": "ai_unavailable"}
    assert provider.calls == []


def test_request_budget_cancels_slow_parse(monkeypatch, client):
    cancelled = {"ok": False, "finished": False}

    async def slow(text, history=None, intent=None, provider=None):
        try:
            await asyncio.sleep(5)
            cancelled["finished"] = True
        except asyncio.CancelledError:
            cancelled["ok"] = True
            raise
        return _ok_result()

    monkeypatch.setenv("REQUEST_TIMEOUT_SECONDS", "0.2")
    monkeypatch.setattr("app.main.parse_request", slow)
    response = client.post(
        "/parse",
        json={"text": "hi"},
        headers={"X-User-Id": "slow-user"},
    )
    assert response.status_code == 503
    assert response.json() == {"error": "ai_unavailable"}
    assert cancelled["ok"] is True
    assert cancelled["finished"] is False


def test_rate_limit_429_then_recovers(monkeypatch, client):
    clock = FakeClock()
    monkeypatch.setattr("app.ai.reliability.clock", clock)
    monkeypatch.setenv("RATE_LIMIT_REQUESTS", "2")
    monkeypatch.setenv("RATE_LIMIT_WINDOW_SECONDS", "10")
    called = {"n": 0}

    async def fake_parse(text, history=None, intent=None, provider=None):
        called["n"] += 1
        return _ok_result()

    monkeypatch.setattr("app.main.parse_request", fake_parse)

    def post(user_id=None):
        headers = {}
        if user_id is not None:
            headers["X-User-Id"] = user_id
        return client.post("/parse", json={"text": "hi"}, headers=headers)

    assert post().status_code == 200
    assert post().status_code == 200
    limited = post()
    assert limited.status_code == 429
    assert limited.json() == {"error": "rate_limited"}
    assert int(limited.headers["Retry-After"]) >= 1
    assert called["n"] == 2
    # A named user does not share the anonymous bucket.
    assert post("user-a").status_code == 200
    assert post("user-a").status_code == 200
    again = post("user-a")
    assert again.status_code == 429
    assert again.headers["Retry-After"]
    clock.advance(10)
    assert post().status_code == 200
    assert post("user-a").status_code == 200
    assert called["n"] == 6
