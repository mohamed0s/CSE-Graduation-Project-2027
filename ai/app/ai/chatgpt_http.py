"""Provider for the internal ChatGPT HTTP server.

The server has no system field and remembers each session_id, so every
call sends one transcript and a new session id.
"""

from __future__ import annotations

import asyncio
import logging
import os
import uuid
from typing import List

import httpx
from pydantic import BaseModel, ValidationError

from .base import LLMProvider, Message
from .errors import AIServiceError
from .usage import record_provider_call

logger = logging.getLogger(__name__)

_DEFAULT_TIMEOUT_SECONDS = 30
_RETRY_DELAY_SECONDS = 0.5
_RETRY_STATUS = {502, 503, 504}


class _ChatGPTHttpResponse(BaseModel):
    """Body returned by the teammate's server."""

    success: bool
    provider: str
    reply: str
    session_id: str
    model: str
    latency_ms: int


class _Transient(Exception):
    """Timeout or 502/503/504. The message stays empty."""

    def __init__(self, error_type: str) -> None:
        self.error_type = error_type


class ChatGPTHttpProvider(LLMProvider):
    """POST {CHATGPT_URL} with one message and a fresh session_id."""

    def __init__(self, transport: httpx.AsyncBaseTransport | None = None) -> None:
        url = os.getenv("CHATGPT_URL", "").strip()
        if not url:
            raise RuntimeError(
                "CHATGPT_URL is not set. Add it to .env for LLM_PROVIDER=chatgpt_http."
            )
        self._url = url
        self._api_key = os.getenv("CHATGPT_API_KEY", "").strip()
        timeout = _timeout_seconds()
        # One client for the life of this provider. transport is for tests.
        self._client = httpx.AsyncClient(timeout=timeout, transport=transport)

    async def complete(self, system: str, messages: List[Message]) -> str:
        message = _build_message(system, messages)
        for attempt in range(2):
            record_provider_call()
            # New id every attempt so a retry cannot resume another call's memory.
            session_id = str(uuid.uuid4())
            try:
                return await self._post(message, session_id)
            except _Transient as exc:
                # Type name only. The cause may contain the URL.
                logger.error("ChatGPT HTTP failed (error_type=%s)", exc.error_type)
                if attempt == 0:
                    await asyncio.sleep(_RETRY_DELAY_SECONDS)
                    continue
                raise AIServiceError("ChatGPT HTTP request failed") from None
            except AIServiceError:
                logger.error("ChatGPT HTTP failed (error_type=AIServiceError)")
                raise
            except Exception as exc:
                logger.error("ChatGPT HTTP failed (error_type=%s)", type(exc).__name__)
                raise AIServiceError("ChatGPT HTTP request failed") from None
        raise AIServiceError("ChatGPT HTTP request failed")

    async def _post(self, message: str, session_id: str) -> str:
        headers = {}
        if self._api_key:
            headers["Authorization"] = f"Bearer {self._api_key}"
        try:
            response = await self._client.post(
                self._url,
                json={"message": message, "session_id": session_id},
                headers=headers,
            )
        except httpx.TimeoutException:
            raise _Transient("TimeoutException") from None
        if response.status_code in _RETRY_STATUS:
            raise _Transient(str(response.status_code))
        if response.status_code < 200 or response.status_code >= 300:
            raise AIServiceError("ChatGPT HTTP request failed")
        try:
            parsed = _ChatGPTHttpResponse.model_validate(response.json())
        except (ValueError, ValidationError):
            raise AIServiceError("ChatGPT HTTP request failed")
        if not parsed.success or not parsed.reply.strip():
            raise AIServiceError("ChatGPT HTTP request failed")
        return parsed.reply


def _build_message(system: str, messages: List[Message]) -> str:
    """System text first, then the same User/Assistant transcript Gemini uses."""
    transcript = "\n".join(
        f"{'User' if m.get('role') == 'user' else 'Assistant'}: {m.get('content', '')}"
        for m in messages
    )
    if not transcript:
        return system
    return f"{system}\n\n{transcript}"


def _timeout_seconds() -> float:
    raw = os.getenv("CHATGPT_TIMEOUT_SECONDS", "").strip()
    if not raw:
        return float(_DEFAULT_TIMEOUT_SECONDS)
    try:
        seconds = float(raw)
    except ValueError as exc:
        raise RuntimeError(
            "CHATGPT_TIMEOUT_SECONDS must be a number of seconds"
        ) from exc
    if seconds <= 0:
        raise RuntimeError("CHATGPT_TIMEOUT_SECONDS must be greater than 0")
    return seconds
