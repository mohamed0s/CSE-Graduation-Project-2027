"""Jev (TypeSafe) intent classifier.

Jev is not a chat model. It returns a calibrated Choice, not text.
This module only classifies. parse_request calls it through the router.
"""

from __future__ import annotations

import logging
import os
from typing import List

from pydantic import BaseModel
from typesafe_sdk import AsyncTypeSafeClient, Choice, RetryPolicy, TypeSafeError

from .errors import AIServiceError
from .intent_criteria import INTENT_CRITERIA, INTENT_INSTRUCTIONS
from .parser import _strip_user_text_tags
from .schemas import Intent

logger = logging.getLogger(__name__)

_DEFAULT_TIMEOUT_SECONDS = 10
_HISTORY_LIMIT = 3


class ClassificationResult(BaseModel):
    """One Jev classification. `model` is the versioned id that answered."""

    intent: Intent
    confidence: float
    p_max: float
    p_second: float
    probabilities: dict[str, float]
    model: str


class JevClassifier:
    """One long-lived async client. Reads TYPESAFE_API_KEY and JEV_MODEL."""

    def __init__(self) -> None:
        api_key = os.getenv("TYPESAFE_API_KEY", "").strip()
        model = os.getenv("JEV_MODEL", "").strip()
        if not api_key:
            raise RuntimeError(
                "TYPESAFE_API_KEY is not set. Add it to .env (see .env.example)."
            )
        if not model:
            raise RuntimeError(
                "JEV_MODEL is not set. Pin a versioned id such as jev-1.13.0. "
                "Do not use jev-latest."
            )
        timeout = _timeout_seconds()
        self._model = model
        # One client for the life of this object. Retry budget is the request
        # timeout, and Retry-After is ignored, so a 429 cannot stall the loop.
        self._client = AsyncTypeSafeClient(
            api_key=api_key,
            model=model,
            timeout=timeout,
            retry=RetryPolicy(
                max_retries=1,
                backoff_initial=0.2,
                backoff_max=0.5,
                timeout=timeout,
                respect_retry_after=False,
            ),
        )

    async def classify(
        self, text: str, history: List[dict] | None = None
    ) -> ClassificationResult:
        """Classify the last user message. History is context only."""
        state = _build_state(text, history)
        try:
            response = await self._client.system_one(
                state=state,
                model=self._model,
                questions={
                    "intent": Choice(
                        instructions=INTENT_INSTRUCTIONS,
                        criteria=INTENT_CRITERIA,
                    )
                },
            )
            answer = response.choices["intent"]
        except TypeSafeError as exc:
            # Type only. Never the key, the user text, or the SDK message.
            logger.error("Jev classify failed (error_type=%s)", type(exc).__name__)
            raise AIServiceError("Jev classification failed") from None
        except (KeyError, AttributeError):
            logger.error("Jev returned an unusable intent answer")
            raise AIServiceError("Jev classification failed") from None

        try:
            intent = Intent(answer.choice)
        except ValueError:
            logger.error("Jev returned an unusable intent answer")
            raise AIServiceError(
                "Jev returned an intent outside the allowed set"
            ) from None

        probabilities = {str(k): float(v) for k, v in answer.probabilities.items()}
        ranked = sorted(probabilities.values(), reverse=True)
        p_max = ranked[0] if ranked else float(answer.confidence)
        p_second = ranked[1] if len(ranked) > 1 else 0.0
        return ClassificationResult(
            intent=intent,
            confidence=float(answer.confidence),
            p_max=p_max,
            p_second=p_second,
            probabilities=probabilities,
            model=response.model,
        )


def _timeout_seconds() -> float:
    """JEV_TIMEOUT_SECONDS, or 10. The SDK timeout is in seconds."""
    raw = os.getenv("JEV_TIMEOUT_SECONDS", "").strip()
    if not raw:
        return float(_DEFAULT_TIMEOUT_SECONDS)
    try:
        seconds = float(raw)
    except ValueError as exc:
        raise RuntimeError("JEV_TIMEOUT_SECONDS must be a number of seconds") from exc
    if seconds <= 0:
        raise RuntimeError("JEV_TIMEOUT_SECONDS must be greater than 0")
    return seconds


def _turn_line(msg: dict) -> str:
    """One history line. Tags are stripped; the wrapper is not added back."""
    content = msg.get("content", "")
    if not isinstance(content, str):
        content = str(content)
    role = msg.get("role", "")
    label = "User" if role == "user" else "Assistant" if role == "assistant" else role
    return f"{label}: {_strip_user_text_tags(content).strip()}"


def _build_state(text: str, history: List[dict] | None) -> str:
    """Last 3 history turns, then the new user message. Tags are stripped.

    When the last history turn is the assistant, the new message is an answer,
    so it is labeled as such. Otherwise the transcript stays flat.
    """
    recent = list(history or [])[-_HISTORY_LIMIT:]
    latest = _strip_user_text_tags(text).strip()
    if recent and recent[-1].get("role") == "assistant":
        earlier = "\n".join(_turn_line(msg) for msg in recent)
        return (
            "Earlier conversation:\n"
            f"{earlier}\n\n"
            "Latest user message (an answer to the assistant's last question): "
            f"{latest}"
        )
    lines = [_turn_line(msg) for msg in recent]
    lines.append(f"User: {latest}")
    return "\n".join(lines)
