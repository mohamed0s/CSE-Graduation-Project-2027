"""In-process circuit breaker, request budget, and per-user rate limit.

State is per process. Tests replace `clock` and call `reset_state()`.
"""

from __future__ import annotations

import asyncio
import logging
import math
import os
import time
from typing import Awaitable, Callable, TypeVar

from .base import LLMProvider, Message
from .errors import AIServiceError

logger = logging.getLogger(__name__)

T = TypeVar("T")

_CLOSED = "closed"
_OPEN = "open"
_HALF_OPEN = "half_open"
_ANONYMOUS = "anonymous"


def clock() -> float:
    """Monotonic seconds. Tests replace this; do not call time.time here."""
    return time.monotonic()


class CircuitOpen(AIServiceError):
    """Breaker is open, so the dependency was not called."""

    def __init__(self) -> None:
        # Fixed text. Never include a URL, key, or user message.
        super().__init__("AI service unavailable")


def _env_int(name: str, default: int, minimum: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        value = int(raw)
    except ValueError:
        return default
    if value < minimum:
        return default
    return value


def _env_float(name: str, default: float, minimum: float) -> float:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        value = float(raw)
    except ValueError:
        return default
    if value < minimum:
        return default
    return value


def failure_limit() -> int:
    """Consecutive AIServiceError/timeout failures before the breaker opens."""
    return _env_int("CIRCUIT_BREAKER_FAILURES", 5, 1)


def cooldown_seconds() -> float:
    """How long an open breaker stays open before one trial call."""
    return _env_float("CIRCUIT_BREAKER_COOLDOWN_SECONDS", 30.0, 0.0)


def request_timeout_seconds() -> float:
    """Whole POST /parse budget. The work is cancelled past this."""
    value = _env_float("REQUEST_TIMEOUT_SECONDS", 25.0, 0.0)
    if value <= 0:
        return 25.0
    return value


def rate_limit_requests() -> int:
    return _env_int("RATE_LIMIT_REQUESTS", 30, 1)


def rate_limit_window() -> float:
    value = _env_float("RATE_LIMIT_WINDOW_SECONDS", 60.0, 0.0)
    if value <= 0:
        return 60.0
    return value


def is_dependency_failure(exc: BaseException) -> bool:
    """AIServiceError or a timeout. Other exceptions are not breaker failures."""
    if isinstance(exc, CircuitOpen):
        return False
    if isinstance(exc, AIServiceError):
        return True
    if isinstance(exc, TimeoutError):
        return True
    return "timeout" in type(exc).__name__.lower()


class CircuitBreaker:
    """Closed, open, then one half-open trial after the cooldown."""

    def __init__(self, name: str) -> None:
        self.name = name
        self._state = _CLOSED
        self._failures = 0
        self._open_until = 0.0
        self._trial = False

    def try_enter(self) -> bool:
        """True if this call may hit the dependency. One trial while half-open."""
        now = clock()
        if self._state == _OPEN:
            if now < self._open_until:
                return False
            self._state = _HALF_OPEN
            self._trial = True
            return True
        if self._state == _HALF_OPEN:
            if self._trial:
                return False
            self._trial = True
            return True
        return True

    def succeed(self) -> None:
        self._state = _CLOSED
        self._failures = 0
        self._trial = False

    def fail(self) -> None:
        """Count a consecutive failure. A bad trial opens the breaker again."""
        self._trial = False
        if self._state == _HALF_OPEN or self._failures + 1 >= failure_limit():
            self._open()
            return
        self._failures += 1

    def release(self) -> None:
        """Call was cancelled or was not a counted failure. Do not trip."""
        self._trial = False

    def _open(self) -> None:
        self._state = _OPEN
        self._failures = 0
        self._trial = False
        self._open_until = clock() + cooldown_seconds()
        logger.error("circuit_open dependency=%s", self.name)


_breakers: dict[str, CircuitBreaker] = {}


def get_breaker(name: str) -> CircuitBreaker:
    breaker = _breakers.get(name)
    if breaker is None:
        breaker = CircuitBreaker(name)
        _breakers[name] = breaker
    return breaker


def jev_breaker() -> CircuitBreaker:
    return get_breaker("jev")


def llm_breaker() -> CircuitBreaker:
    """One breaker for the provider selected by LLM_PROVIDER."""
    name = os.getenv("LLM_PROVIDER", "").strip().lower() or "unset"
    return get_breaker(f"llm:{name}")


async def call_dependency(
    breaker: CircuitBreaker,
    func: Callable[[], Awaitable[T]],
) -> T:
    """Run `func` unless the breaker is open. Records AIServiceError and timeouts."""
    if not breaker.try_enter():
        raise CircuitOpen()
    try:
        result = await func()
    except asyncio.CancelledError:
        breaker.release()
        raise
    except Exception as exc:
        if is_dependency_failure(exc):
            breaker.fail()
        else:
            breaker.release()
        raise
    else:
        breaker.succeed()
        return result


class _GuardedProvider(LLMProvider):
    """Delegates complete(). The LLM breaker sees each attempt."""

    def __init__(self, inner: LLMProvider) -> None:
        self._inner = inner

    async def complete(self, system: str, messages: list[Message]) -> str:
        return await call_dependency(
            llm_breaker(),
            lambda: self._inner.complete(system, messages),
        )


def guard_llm(provider: LLMProvider) -> LLMProvider:
    """Wrap a provider without changing its complete() contract."""
    if isinstance(provider, _GuardedProvider):
        return provider
    return _GuardedProvider(provider)


class RateLimiter:
    """Sliding window of request timestamps, keyed by user bucket."""

    def __init__(self) -> None:
        self._hits: dict[str, list[float]] = {}

    def reset(self) -> None:
        self._hits.clear()

    def retry_after(self, user: str) -> int | None:
        """Record a hit, or return Retry-After seconds when the bucket is full."""
        now = clock()
        window = rate_limit_window()
        limit = rate_limit_requests()
        hits = [stamp for stamp in self._hits.get(user, []) if now - stamp < window]
        if len(hits) >= limit:
            self._hits[user] = hits
            wait = math.ceil(window - (now - hits[0]))
            return max(1, wait)
        hits.append(now)
        self._hits[user] = hits
        return None


rate_limiter = RateLimiter()


def user_bucket(header: str | None) -> str:
    """X-User-Id, or one shared bucket when the header is missing or blank."""
    value = (header or "").strip()
    if not value or len(value) > 200:
        return _ANONYMOUS
    return value


def reset_state() -> None:
    """Drop breaker and rate-limit state. Tests only."""
    _breakers.clear()
    rate_limiter.reset()
