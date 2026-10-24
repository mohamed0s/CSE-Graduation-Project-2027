"""Router tests. FakeProvider and a fake Jev; no network."""

import logging

import pytest

from app.ai.base import LLMProvider
from app.ai.errors import AIServiceError
from app.ai.jev import ClassificationResult
from app.ai.parser import parse_request
from app.ai.schemas import Intent


def _run(coro):
    import asyncio

    return asyncio.run(coro)


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


class FakeJev:
    def __init__(self, result=None, error=None):
        self.result = result
        self.error = error
        self.calls = 0

    async def classify(self, text, history=None):
        self.calls += 1
        if self.error is not None:
            raise self.error
        return self.result


def _jev_result(intent, confidence, probabilities, model="jev-1.13.0-test"):
    ranked = sorted(probabilities.values(), reverse=True)
    return ClassificationResult(
        intent=intent,
        confidence=confidence,
        p_max=ranked[0],
        p_second=ranked[1] if len(ranked) > 1 else 0.0,
        probabilities=probabilities,
        model=model,
    )


def _use_jev(monkeypatch, fake):
    monkeypatch.setenv("CLASSIFIER_PROVIDER", "jev")
    monkeypatch.setattr("app.ai.router._get_jev", lambda: fake)


def test_high_confidence_action_skips_gemini_classify(monkeypatch):
    fake = FakeJev(
        _jev_result(
            Intent.search_service,
            0.86,
            {"search_service": 0.86, "unknown": 0.08, "app_help": 0.06},
        )
    )
    _use_jev(monkeypatch, fake)
    provider = FakeProvider(['{"category": "سباك", "location": "الدقي"}'])
    result = _run(parse_request("نص مختلف عن التقييم", provider=provider))
    assert result.intent is Intent.search_service
    assert result.classifier == "jev"
    assert result.fallback_used is False
    assert result.classifier_confidence == 0.86
    assert result.jev_model == "jev-1.13.0-test"
    assert fake.calls == 1
    assert len(provider.calls) == 1


def test_low_confidence_falls_back_to_gemini(monkeypatch, caplog):
    fake = FakeJev(
        _jev_result(
            Intent.search_service,
            0.41,
            {"search_service": 0.41, "unknown": 0.2, "app_help": 0.1},
        )
    )
    _use_jev(monkeypatch, fake)
    sentence = "UNIQUE_ROUTER_SENTENCE_SHOULD_NOT_BE_LOGGED"
    provider = FakeProvider(
        [
            '{"intent": "budget_recommendation"}',
            '{"item_type": "شقة", "budget": 4000, "location": "الهرم"}',
        ]
    )
    with caplog.at_level(logging.INFO):
        result = _run(parse_request(sentence, provider=provider))
    assert result.intent is Intent.budget_recommendation
    assert result.fallback_used is True
    assert result.classifier == "gemini"
    assert result.jev_model == "jev-1.13.0-test"
    assert len(provider.calls) == 2
    assert sentence not in caplog.text
    assert "fallback_used=True" in caplog.text
    assert "latency_ms=" in caplog.text


def test_jev_error_falls_back(monkeypatch):
    fake = FakeJev(error=AIServiceError("Jev classification failed"))
    _use_jev(monkeypatch, fake)
    provider = FakeProvider(
        [
            '{"intent": "place_order"}',
            '{"item": "كشري", "provider": "أبو طارق"}',
        ]
    )
    result = _run(parse_request("ابعتلي حاجة", provider=provider))
    assert result.intent is Intent.place_order
    assert result.fallback_used is True
    assert result.classifier_confidence is None
    assert len(provider.calls) == 2


def test_jev_and_gemini_both_fail(monkeypatch):
    fake = FakeJev(error=AIServiceError("Jev classification failed"))
    _use_jev(monkeypatch, fake)
    provider = FakeProvider([RuntimeError("gemini down")])
    with pytest.raises(AIServiceError):
        _run(parse_request("ابعتلي حاجة", provider=provider))
    assert len(provider.calls) == 1


def test_group_rule_skips_gemini_and_extract(monkeypatch):
    fake = FakeJev(
        _jev_result(
            Intent.search_service,
            0.4,
            {"search_service": 0.4, "app_help": 0.35, "unknown": 0.25},
        )
    )
    _use_jev(monkeypatch, fake)
    provider = FakeProvider(["should not be called"])
    result = _run(parse_request("مش عارف", provider=provider))
    assert result.intent is Intent.app_help
    assert result.classifier == "jev"
    assert result.fallback_used is False
    assert result.classifier_confidence == 0.35
    assert fake.calls == 1
    assert provider.calls == []


def test_gemini_provider_keeps_today_call_counts(monkeypatch):
    monkeypatch.setenv("CLASSIFIER_PROVIDER", "gemini")
    provider = FakeProvider(
        [
            '{"intent": "search_service"}',
            '{"category": "سباك", "location": "الدقي"}',
        ]
    )
    result = _run(parse_request("عايز سباك في الدقي", provider=provider))
    assert result.intent is Intent.search_service
    assert result.classifier == "gemini"
    assert result.fallback_used is False
    assert result.jev_model is None
    assert len(provider.calls) == 2


def test_explicit_intent_skips_classification(monkeypatch):
    fake = FakeJev(
        _jev_result(Intent.search_service, 0.99, {"search_service": 0.99})
    )
    _use_jev(monkeypatch, fake)
    provider = FakeProvider(['{"order_id": "99"}'])
    result = _run(
        parse_request("وين طلبي 99؟", intent=Intent.track_order, provider=provider)
    )
    assert result.intent is Intent.track_order
    assert result.fields == {"order_id": "99"}
    assert fake.calls == 0
    assert len(provider.calls) == 1
    assert result.classifier is None


def test_classifier_provider_must_be_set(monkeypatch):
    monkeypatch.delenv("CLASSIFIER_PROVIDER", raising=False)
    from app.ai.router import classify

    with pytest.raises(RuntimeError, match="CLASSIFIER_PROVIDER"):
        _run(classify("hello", []))
