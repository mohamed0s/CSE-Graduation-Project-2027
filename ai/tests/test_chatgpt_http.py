"""ChatGPT HTTP provider tests. MockTransport only; no network."""

import json
import logging

import httpx
import pytest

from app.ai.chatgpt_http import ChatGPTHttpProvider
from app.ai.errors import AIServiceError

_URL = "http://chatgpt.test/chat"
_KEY = "sk-chatgpt-test-not-real"
_SYSTEM = "SYSTEM_TEXT_UNIQUE"
_USER = "USER_TURN_UNIQUE"
_ASSISTANT = "ASSISTANT_TURN_UNIQUE"
_REPLY = "REPLY_BODY_UNIQUE"


def _run(coro):
    import asyncio

    return asyncio.run(coro)


def _payload(**overrides):
    body = {
        "success": True,
        "provider": "chatgpt",
        "reply": _REPLY,
        "session_id": "server-session",
        "model": "gpt-test",
        "latency_ms": 12,
    }
    body.update(overrides)
    return body


def _provider(monkeypatch, handler, api_key=None):
    monkeypatch.setenv("CHATGPT_URL", _URL)
    if api_key is None:
        monkeypatch.delenv("CHATGPT_API_KEY", raising=False)
    else:
        monkeypatch.setenv("CHATGPT_API_KEY", api_key)
    monkeypatch.delenv("CHATGPT_TIMEOUT_SECONDS", raising=False)

    async def no_sleep(seconds):
        return None

    monkeypatch.setattr("app.ai.chatgpt_http.asyncio.sleep", no_sleep)
    return ChatGPTHttpProvider(transport=httpx.MockTransport(handler))


def test_success_sends_system_transcript_and_new_sessions(monkeypatch):
    seen = []

    def handler(request: httpx.Request) -> httpx.Response:
        seen.append(json.loads(request.content))
        assert request.url == _URL
        assert "authorization" not in {name.lower() for name in request.headers}
        return httpx.Response(200, json=_payload())

    provider = _provider(monkeypatch, handler)
    messages = [
        {"role": "user", "content": _USER},
        {"role": "assistant", "content": _ASSISTANT},
    ]
    assert _run(provider.complete(_SYSTEM, messages)) == _REPLY
    assert _run(provider.complete(_SYSTEM, messages)) == _REPLY
    assert seen[0]["session_id"] != seen[1]["session_id"]
    message = seen[0]["message"]
    assert message.startswith(_SYSTEM)
    assert f"User: {_USER}" in message
    assert f"Assistant: {_ASSISTANT}" in message


def test_authorization_header_only_when_key_is_set(monkeypatch):
    def handler(request: httpx.Request) -> httpx.Response:
        assert request.headers["authorization"] == f"Bearer {_KEY}"
        return httpx.Response(200, json=_payload())

    provider = _provider(monkeypatch, handler, api_key=_KEY)
    assert _run(provider.complete("sys", [])) == _REPLY


@pytest.mark.parametrize(
    "response",
    [
        httpx.Response(200, json=_payload(success=False, reply="nope")),
        httpx.Response(200, json=_payload(reply="  ")),
        httpx.Response(200, text="not-json"),
        httpx.Response(500, json={"error": "UNIQUE_RESPONSE_BODY"}),
    ],
)
def test_bad_responses_raise_without_leaking(monkeypatch, response, caplog):
    calls = {"n": 0}

    def handler(request: httpx.Request) -> httpx.Response:
        calls["n"] += 1
        return response

    provider = _provider(monkeypatch, handler, api_key=_KEY)
    with caplog.at_level(logging.ERROR):
        with pytest.raises(AIServiceError, match="ChatGPT HTTP request failed") as caught:
            _run(provider.complete(_SYSTEM, [{"role": "user", "content": _USER}]))
    assert calls["n"] == 1
    blob = str(caught.value) + caplog.text
    assert _URL not in blob
    assert _KEY not in blob
    assert _SYSTEM not in blob
    assert _USER not in blob
    assert "UNIQUE_RESPONSE_BODY" not in blob
    assert "nope" not in blob


def test_401_is_not_retried(monkeypatch):
    calls = {"n": 0}

    def handler(request: httpx.Request) -> httpx.Response:
        calls["n"] += 1
        return httpx.Response(401, json={"error": "unauthorized"})

    provider = _provider(monkeypatch, handler)
    with pytest.raises(AIServiceError):
        _run(provider.complete("sys", []))
    assert calls["n"] == 1


def test_timeout_then_success_retries_once(monkeypatch):
    calls = {"n": 0}

    def handler(request: httpx.Request) -> httpx.Response:
        calls["n"] += 1
        if calls["n"] == 1:
            raise httpx.TimeoutException("timed out")
        return httpx.Response(200, json=_payload())

    provider = _provider(monkeypatch, handler)
    assert _run(provider.complete("sys", [])) == _REPLY
    assert calls["n"] == 2


def test_missing_url_raises(monkeypatch):
    monkeypatch.delenv("CHATGPT_URL", raising=False)
    with pytest.raises(RuntimeError, match="CHATGPT_URL"):
        ChatGPTHttpProvider()


def test_get_provider_selects_chatgpt_http(monkeypatch):
    from app.ai import get_provider

    get_provider.cache_clear()
    monkeypatch.setenv("LLM_PROVIDER", "chatgpt_http")
    monkeypatch.setenv("CHATGPT_URL", _URL)
    monkeypatch.delenv("CHATGPT_API_KEY", raising=False)
    try:
        provider = get_provider()
        assert isinstance(provider, ChatGPTHttpProvider)
        assert get_provider() is provider
    finally:
        get_provider.cache_clear()
