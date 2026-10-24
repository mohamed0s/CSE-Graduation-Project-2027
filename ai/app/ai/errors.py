"""Errors raised by the AI service (never include keys or prompts)."""


class AIServiceError(Exception):
    """The LLM provider failed.

    Raised instead of the raw provider exception so callers get one error
    type. Parse mistakes (bad JSON) are not this error — those are retried.
    """
