"""App-help and unknown replies. Fake handler, no model calls."""

import logging

import pytest

from app.ai.app_help import AppHelpAnswer
from app.ai.base import LLMProvider
from app.ai.parser import parse_request
from app.ai.replies import NOT_AVAILABLE, UNKNOWN_REPLY, compose_reply
from app.ai.schemas import Intent


def _run(coro):
    import asyncio

    return asyncio.run(coro)


class FakeProvider(LLMProvider):
    def __init__(self):
        self.calls = []

    async def complete(self, system, messages):
        self.calls.append((system, list(messages)))
        raise AssertionError("app help must not call the model")


class FakeHandler:
    def __init__(self, answer=None, error=None):
        self.answer_value = answer
        self.error = error
        self.calls = 0

    async def answer(self, question, history):
        self.calls += 1
        if self.error is not None:
            raise self.error
        return self.answer_value


def _patch(monkeypatch, handler):
    monkeypatch.setattr("app.ai.replies.get_app_help_handler", lambda: handler)


def test_app_help_uses_handler_and_makes_no_model_call(monkeypatch):
    handler = FakeHandler(AppHelpAnswer(text="تدفع من صفحة الدفع.", score=0.9))
    _patch(monkeypatch, handler)
    provider = FakeProvider()
    result = _run(
        parse_request("ازاي أدفع؟", intent=Intent.app_help, provider=provider)
    )
    assert result.reply_text == "تدفع من صفحة الدفع."
    assert handler.calls == 1
    assert provider.calls == []


def test_handler_none_uses_not_available_template(monkeypatch):
    sentence = "UNIQUE_HELP_QUESTION_NOT_IN_TEMPLATE"
    handler = FakeHandler(None)
    _patch(monkeypatch, handler)
    reply = _run(compose_reply(Intent.app_help, sentence, [], None))
    assert reply == NOT_AVAILABLE
    assert sentence not in reply


def test_low_confidence_unknown_tries_handler_first(monkeypatch):
    handler = FakeHandler(AppHelpAnswer(text="من الإعدادات.", score=None))
    _patch(monkeypatch, handler)
    reply = _run(compose_reply(Intent.unknown, "سؤال غامض", [], 0.2))
    assert handler.calls == 1
    assert reply == "من الإعدادات."


def test_high_confidence_unknown_skips_handler(monkeypatch):
    handler = FakeHandler(AppHelpAnswer(text="should not be used"))
    _patch(monkeypatch, handler)
    sentence = "UNIQUE_UNKNOWN_SENTENCE"
    reply = _run(compose_reply(Intent.unknown, sentence, [], 0.91))
    assert handler.calls == 0
    assert reply == UNKNOWN_REPLY
    assert sentence not in reply
    none_confidence = _run(compose_reply(Intent.unknown, sentence, [], None))
    assert handler.calls == 0
    assert none_confidence == UNKNOWN_REPLY


def test_handler_exception_uses_template(monkeypatch, caplog):
    handler = FakeHandler(error=RuntimeError("rag down"))
    _patch(monkeypatch, handler)
    sentence = "UNIQUE_CRASH_QUESTION"
    with caplog.at_level(logging.ERROR):
        reply = _run(compose_reply(Intent.app_help, sentence, [], None))
    assert reply == NOT_AVAILABLE
    assert sentence not in caplog.text
    assert "RuntimeError" in caplog.text


def test_score_below_minimum_uses_template(monkeypatch):
    monkeypatch.setenv("APP_HELP_MIN_SCORE", "0.5")
    handler = FakeHandler(AppHelpAnswer(text="إجابة ضعيفة", score=0.2))
    _patch(monkeypatch, handler)
    reply = _run(compose_reply(Intent.app_help, "سؤال", [], None))
    assert reply == NOT_AVAILABLE
    assert "إجابة ضعيفة" not in reply
