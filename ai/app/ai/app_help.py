"""App-help answers come from a teammate's RAG handler, not from a model.

All callers use get_app_help_handler(). The real implementation (probably an
HTTP call over the app documents) is not defined here.
"""

from __future__ import annotations

from typing import Protocol

from pydantic import BaseModel

from .base import Message


class AppHelpAnswer(BaseModel):
    """One relevant answer. score is optional until the RAG handler sets it."""

    text: str
    score: float | None = None


class AppHelpHandler(Protocol):
    """Look up app documents. None means nothing relevant was found."""

    async def answer(
        self, question: str, history: list[Message]
    ) -> AppHelpAnswer | None:
        """Return an answer, or None when no document applies."""
        ...


class NullAppHelpHandler:
    """Placeholder until the RAG handler is wired in."""

    async def answer(
        self, question: str, history: list[Message]
    ) -> AppHelpAnswer | None:
        return None


def get_app_help_handler() -> AppHelpHandler:
    """The only way to obtain the app-help handler."""
    return NullAppHelpHandler()
