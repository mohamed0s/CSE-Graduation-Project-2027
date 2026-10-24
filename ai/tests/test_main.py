"""HTTP API tests. Fake provider only; no network."""

import pytest
from fastapi.testclient import TestClient

from app.ai.base import LLMProvider
from app.ai.errors import AIServiceError
from app.main import app


class FakeProvider(LLMProvider):
    def __init__(self, outputs):
        self.outputs = list(outputs)
        self.calls = []

    async def complete(self, system, messages):
        self.calls.append((system, list(messages)))
        out = self.outputs.pop(0)
        if isinstance(out, Exception):
            raise out
        return out


@pytest.fixture
def client():
    return TestClient(app)


def _use_provider(monkeypatch, provider):
    monkeypatch.setattr("app.ai.get_provider", lambda: provider)


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}
    assert response.headers["X-Request-ID"]


def test_parse_ask_user_and_ready(client, monkeypatch):
    provider = FakeProvider(
        [
            '{"intent": "search_service"}',
            '{"category": "سباك", "location": null}',
            '{"intent": "track_order"}',
            '{"order_id": "99"}',
        ]
    )
    _use_provider(monkeypatch, provider)
    asking = client.post(
        "/parse",
        json={"text": "عايز سباك"},
        headers={"X-Request-ID": "req-ask"},
    )
    assert asking.status_code == 200
    assert asking.headers["X-Request-ID"] == "req-ask"
    body = asking.json()
    assert body["intent"] == "search_service"
    assert body["clarifying_question"]
    assert body["next_action"] == "ask_user"
    assert "classifier" in body

    ready = client.post("/parse", json={"text": "وين طلبي 99"})
    assert ready.status_code == 200
    assert ready.json()["next_action"] == "ready"
    assert ready.json()["fields"]["order_id"] == "99"
    assert ready.json()["reply_text"] is None
    assert ready.headers["X-Request-ID"]


def test_parse_reply_for_app_help(client, monkeypatch):
    provider = FakeProvider(['{"intent": "app_help"}'])
    _use_provider(monkeypatch, provider)
    response = client.post("/parse", json={"text": "ازاي أدفع؟", "history": []})
    assert response.status_code == 200
    body = response.json()
    assert body["intent"] == "app_help"
    assert body["reply_text"]
    assert body["next_action"] == "reply"
    assert provider.calls  # classify only; extract does not call the model


def test_validation_errors_are_422(client):
    too_long = client.post("/parse", json={"text": "x" * 1001})
    assert too_long.status_code == 422
    too_many = client.post(
        "/parse",
        json={"text": "hi", "history": [{"role": "user", "content": "a"}] * 7},
    )
    assert too_many.status_code == 422
    bad_role = client.post(
        "/parse",
        json={"text": "hi", "history": [{"role": "system", "content": "no"}]},
    )
    assert bad_role.status_code == 422


def test_ai_error_is_503_without_secrets(client, monkeypatch):
    secret = "sk-live-should-not-leak"
    prompt = "You are Finda, secret prompt text"

    async def boom(text, history=None, intent=None, provider=None):
        raise AIServiceError(f"{secret} {prompt}")

    monkeypatch.setattr("app.main.parse_request", boom)
    response = client.post(
        "/parse",
        json={"text": "عايز سباك"},
        headers={"X-Request-ID": "req-down"},
    )
    assert response.status_code == 503
    assert response.json() == {"error": "ai_unavailable"}
    assert secret not in response.text
    assert prompt not in response.text
    assert response.headers["X-Request-ID"] == "req-down"


def test_ready_checks_env_without_calling_provider(monkeypatch, client):
    monkeypatch.setenv("CLASSIFIER_PROVIDER", "gemini")
    monkeypatch.setenv("LLM_PROVIDER", "gemini_native")
    monkeypatch.setenv("LLM_API_KEY", "test-key-not-real")
    ok = client.get("/ready")
    assert ok.status_code == 200
    assert ok.json() == {"ready": True}
    assert "test-key-not-real" not in ok.text

    monkeypatch.delenv("LLM_API_KEY", raising=False)
    missing = client.get("/ready")
    assert missing.status_code == 503
    assert missing.json()["ready"] is False
    assert "LLM_API_KEY" in missing.json()["missing"]
    assert "test-key-not-real" not in missing.text

    monkeypatch.setenv("CLASSIFIER_PROVIDER", "jev")
    monkeypatch.setenv("LLM_API_KEY", "test-key-not-real")
    monkeypatch.delenv("TYPESAFE_API_KEY", raising=False)
    monkeypatch.delenv("JEV_MODEL", raising=False)
    jev = client.get("/ready")
    assert jev.status_code == 503
    assert "TYPESAFE_API_KEY" in jev.json()["missing"]
    assert "JEV_MODEL" in jev.json()["missing"]
