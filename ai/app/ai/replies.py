"""Fixed Arabic replies for app_help and unknown. No model call."""

from __future__ import annotations

import logging
import os

from .app_help import AppHelpAnswer, get_app_help_handler
from .base import Message
from .schemas import Intent

logger = logging.getLogger(__name__)

# Fixed text. Never interpolate the user's message into these.
NOT_AVAILABLE = "معلش، ملقتش المعلومة دي."
UNKNOWN_REPLY = (
    "أنا فيندا. أقدر أساعدك تلاقي خدمة، أرشحلك حاجة على قد ميزانيتك، "
    "أديك أفكار لمكان فاضي، أطلبلك حاجة، أو أتابع طلبك."
)


async def compose_reply(
    intent: Intent,
    text: str,
    history: list[Message],
    confidence: float | None,
) -> str:
    """Reply for app_help or unknown. Other intents are not handled here."""
    if intent is Intent.app_help:
        answer = await _safe_answer(text, history)
        return answer.text if answer is not None else NOT_AVAILABLE
    if intent is Intent.unknown:
        # None means Gemini classified it. Treat that as confident.
        if confidence is None or confidence >= _confidence_threshold():
            return UNKNOWN_REPLY
        answer = await _safe_answer(text, history)
        return answer.text if answer is not None else UNKNOWN_REPLY
    return ""


async def _safe_answer(question: str, history: list[Message]) -> AppHelpAnswer | None:
    """Ask the handler. A failure becomes 'no answer', not a crashed request."""
    try:
        answer = await get_app_help_handler().answer(question, history)
    except Exception as exc:
        logger.error("app help handler failed (error_type=%s)", type(exc).__name__)
        return None
    return _accepted(answer)


def _accepted(answer: AppHelpAnswer | None) -> AppHelpAnswer | None:
    if answer is None or not answer.text:
        return None
    if answer.score is None:
        return answer
    if answer.score < _min_score():
        return None
    return answer


def _confidence_threshold() -> float:
    raw = os.getenv("CONFIDENCE_THRESHOLD", "").strip()
    if not raw:
        return 0.7
    return float(raw)


def _min_score() -> float:
    raw = os.getenv("APP_HELP_MIN_SCORE", "").strip()
    if not raw:
        return 0.0
    return float(raw)
