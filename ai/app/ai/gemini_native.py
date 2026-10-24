from __future__ import annotations

import asyncio
import logging
import os
import re
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from typing import List

from .base import LLMProvider, Message
from .errors import AIServiceError
from .usage import record_provider_call

logger = logging.getLogger(__name__)


# interactions.create(timeout=...) is seconds. HttpOptions.timeout is milliseconds.
_DEFAULT_TIMEOUT_SECONDS = 120
# A Retry-After longer than this is a daily quota, not a short blip.
_MAX_RATE_LIMIT_WAIT_SECONDS = 60
# One try, then up to 3 retries. Waits are 2s, 4s, 8s. Not used for 4xx.
_TRANSIENT_BACKOFF_SECONDS = (2, 4, 8)


def _timeout_seconds() -> float:
    """Seconds to wait for Gemini. GEMINI_TIMEOUT_SECONDS overrides 120."""
    raw = os.getenv("GEMINI_TIMEOUT_SECONDS", "").strip()
    if not raw:
        return float(_DEFAULT_TIMEOUT_SECONDS)
    try:
        seconds = float(raw)
    except ValueError as exc:
        raise RuntimeError("GEMINI_TIMEOUT_SECONDS must be a number of seconds") from exc
    if seconds <= 0:
        raise RuntimeError("GEMINI_TIMEOUT_SECONDS must be greater than 0")
    return seconds


_RETRY_DELAY_RE = re.compile(
    r"(?:retryDelay|retry_delay)[\"']?\s*[:=]\s*[\"']?(?P<value>\d+(?:\.\d+)?)s"
    r"|retry in (?P<value2>\d+(?:\.\d+)?)s",
    re.IGNORECASE,
)


class GeminiNativeProvider(LLMProvider):
    """Uses Google's native Gemini API via the google-genai SDK.

    Endpoint (June 2026+): https://generativelanguage.googleapis.com
    Default model: gemini-3.8-flash
    Override both via LLM_BASE_URL / LLM_MODEL in .env if needed.

    The Interactions API accepts generation_config.temperature and a
    per-request timeout (seconds) on interactions.create().
    The client timeout is HttpOptions.timeout in milliseconds.
    Optional GEMINI_TIMEOUT_SECONDS overrides the 120s default.
    """

    def __init__(self) -> None:
        self.api_key = os.getenv("LLM_API_KEY", "")
        self.model = os.getenv("LLM_MODEL") or "gemini-3.8-flash"
        self.timeout_seconds = _timeout_seconds()
        base_url = os.getenv("LLM_BASE_URL", "").strip()
        if not self.api_key:
            raise RuntimeError("LLM_API_KEY must be set for gemini_native")

        from google import genai  # imported lazily so openai_compat users don't need it

        # HttpOptions.timeout is milliseconds (google.genai.types.HttpOptions).
        # attempts 0 or 1 means no retries (types.HttpRetryOptions). The
        # Interactions client copies `attempts` into max_retries and sleeps
        # on Retry-After before that count is exhausted — a 429 delay can be
        # hours — so 0 is what actually skips the sleep. 429 is also left
        # out of the retryable status codes.
        http_options: dict = {
            # types.HttpOptions.timeout is milliseconds, not seconds.
            "timeout": int(self.timeout_seconds * 1000),
            "retry_options": {
                "attempts": 0,
                "http_status_codes": [408, 500, 502, 503, 504],
            },
        }
        if base_url:
            http_options["base_url"] = base_url
        self._client = genai.Client(api_key=self.api_key, http_options=http_options)

    async def complete(self, system: str, messages: List[Message]) -> str:
        # Flatten chat history into one text transcript; the Interactions API
        # takes a single `input` value per turn.
        transcript = "\n".join(
            f"{'User' if m['role'] == 'user' else 'Assistant'}: {m['content']}"
            for m in messages
        )
        attempts = 1 + len(_TRANSIENT_BACKOFF_SECONDS)
        for attempt in range(attempts):
            record_provider_call()
            try:
                interaction = await self._client.aio.interactions.create(
                    model=self.model,
                    input=transcript,
                    system_instruction=system,
                    generation_config={"temperature": 0.2},
                    timeout=self.timeout_seconds,
                    # Do not store user messages on Google's side.
                    store=False,
                )
            except AIServiceError:
                raise
            except Exception as exc:
                rate_limit = _rate_limit_error(exc)
                if rate_limit is not None:
                    # Never sleep here. A delay over 60s must not be waited out.
                    raise rate_limit from exc
                # 4xx (400/401/403/404/...) is the caller's problem. Retry only
                # 503, "high demand", and timeouts.
                if attempt == attempts - 1 or not _is_transient(exc):
                    raise
                delay = _TRANSIENT_BACKOFF_SECONDS[attempt]
                logger.warning(
                    "Gemini transient error (type=%s); retrying in %s seconds",
                    type(exc).__name__,
                    delay,
                )
                await asyncio.sleep(delay)
                continue
            # None is an empty reply, not a crash. The parser retries bad JSON.
            return interaction.output_text or ""
        raise RuntimeError("Gemini retry loop exited without a result")


def _rate_limit_error(exc: BaseException) -> AIServiceError | None:
    """Turn an HTTP 429 into AIServiceError. Does not wait or retry."""
    if _status_code(exc) != 429:
        return None
    delay = _retry_delay_seconds(exc)
    message = "Gemini rate limit (429)"
    if delay is not None:
        message = f"{message}; retry after {delay:g} seconds"
    if delay is not None and delay > _MAX_RATE_LIMIT_WAIT_SECONDS:
        logger.error(
            "Gemini rate limit (429); retry delay %s seconds exceeds %s, not waiting",
            delay,
            _MAX_RATE_LIMIT_WAIT_SECONDS,
        )
    else:
        logger.error("Gemini rate limit (429)")
    return AIServiceError(message)


def _is_transient(exc: BaseException) -> bool:
    """True for 503, high-demand, and timeouts. Never for 4xx."""
    status = _http_status(exc)
    if status is not None and 400 <= status < 500:
        return False
    if status == 503:
        return True
    if isinstance(exc, TimeoutError) or "timeout" in type(exc).__name__.lower():
        return True
    text = str(exc)
    message = getattr(exc, "message", None)
    if message:
        text = f"{text} {message}"
    return "high demand" in text.lower()


def _http_status(exc: BaseException) -> int | None:
    """HTTP status from the exception or its response, if one is present."""
    for obj in (exc, getattr(exc, "response", None), getattr(exc, "raw_response", None)):
        if obj is None:
            continue
        for attr in ("status_code", "code"):
            value = getattr(obj, attr, None)
            if isinstance(value, int) and 100 <= value <= 599:
                return value
            if isinstance(value, str) and value.isdigit() and len(value) == 3:
                return int(value)
    return None


def _status_code(exc: BaseException) -> int | None:
    objects = [exc, getattr(exc, "response", None), getattr(exc, "raw_response", None)]
    for obj in objects:
        if obj is None:
            continue
        for attr in ("status_code", "code"):
            value = getattr(obj, attr, None)
            if value == 429 or value == "429":
                return 429
    return None


def _retry_delay_seconds(exc: BaseException) -> float | None:
    texts: list[str] = []
    for obj in (exc, getattr(exc, "response", None), getattr(exc, "raw_response", None)):
        if obj is None:
            continue
        delay = _delay_from_headers(getattr(obj, "headers", None))
        if delay is not None:
            return delay
        for attr in ("text", "body", "message", "details"):
            value = getattr(obj, attr, None)
            if value:
                texts.append(value if isinstance(value, str) else str(value))
    texts.append(str(exc))
    for text in texts:
        delay = _delay_from_text(text)
        if delay is not None:
            return delay
    return None


def _delay_from_headers(headers) -> float | None:
    if not headers:
        return None
    getter = getattr(headers, "get", None)
    if getter is None:
        return None
    retry_after_ms = getter("retry-after-ms")
    if retry_after_ms:
        try:
            return float(retry_after_ms) / 1000
        except (TypeError, ValueError):
            pass
    retry_after = getter("retry-after") or getter("Retry-After")
    if not retry_after:
        return None
    try:
        return float(retry_after)
    except (TypeError, ValueError):
        pass
    try:
        retry_date = parsedate_to_datetime(str(retry_after))
        if retry_date.tzinfo is None:
            retry_date = retry_date.replace(tzinfo=timezone.utc)
        return max(0.0, (retry_date - datetime.now(retry_date.tzinfo)).total_seconds())
    except (TypeError, ValueError, OverflowError):
        return None


def _delay_from_text(text: str) -> float | None:
    match = _RETRY_DELAY_RE.search(text)
    if not match:
        return None
    raw = match.group("value") or match.group("value2")
    return float(raw)
