"""Process-wide count of LLM provider calls.

Both providers increment this from complete(). It is not reset, so a
long-running process keeps a running total.
"""

_calls = 0


def record_provider_call() -> None:
    """Count one provider.complete() attempt, including failures."""
    global _calls
    _calls += 1


def provider_call_count() -> int:
    return _calls
