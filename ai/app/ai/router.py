"""Choose an intent with Jev, and fall back to Gemini when Jev is unsure.

get_provider() is still the Gemini provider. It is used for extraction and
for this fallback. There is no other provider switch here.
"""

from __future__ import annotations

import logging
import os
import time
from dataclasses import dataclass
from typing import Optional

from .base import LLMProvider
from .schemas import Intent

logger = logging.getLogger(__name__)

_ACTION_INTENTS = frozenset(
    {
        Intent.search_service,
        Intent.budget_recommendation,
        Intent.space_idea,
        Intent.place_order,
        Intent.track_order,
    }
)
_GROUP = ("app_help", "unknown")


@dataclass
class RoutedIntent:
    """Who classified this turn, and whether Gemini had to take over."""

    intent: Intent
    classifier: str
    confidence: Optional[float]
    fallback_used: bool
    jev_model: Optional[str]


async def classify(
    text: str,
    history,
    provider: Optional[LLMProvider] = None,
) -> RoutedIntent:
    """Classify one turn. CLASSIFIER_PROVIDER must be jev or gemini."""
    name = os.getenv("CLASSIFIER_PROVIDER", "").strip().lower()
    if not name:
        raise RuntimeError(
            "CLASSIFIER_PROVIDER is not set. Set it to 'jev' or 'gemini'."
        )
    started = time.perf_counter()
    if name == "gemini":
        intent = await _gemini_intent(text, history, provider)
        routed = RoutedIntent(
            intent=intent,
            classifier="gemini",
            confidence=None,
            fallback_used=False,
            jev_model=None,
        )
        _log(routed, p_max=None, p_second=None, started=started)
        return routed
    if name != "jev":
        raise RuntimeError(
            f"Unknown CLASSIFIER_PROVIDER: {name!r}. Expected 'jev' or 'gemini'."
        )

    jev_result = None
    try:
        # Open breaker skips Jev. Timeouts and AIServiceError fall back too.
        jev_result = await _call_jev(text, history)
    except Exception:
        # Provider failure must not become an unhandled 500.
        intent = await _gemini_intent(text, history, provider)
        routed = RoutedIntent(
            intent=intent,
            classifier="gemini",
            confidence=None,
            fallback_used=True,
            jev_model=None,
        )
        _log(routed, p_max=None, p_second=None, started=started)
        return routed

    group_choice = _group_choice(jev_result.probabilities)
    if group_choice is not None:
        routed = RoutedIntent(
            intent=group_choice[0],
            classifier="jev",
            confidence=group_choice[1],
            fallback_used=False,
            jev_model=jev_result.model,
        )
        _log(routed, jev_result.p_max, jev_result.p_second, started)
        return routed

    if (
        jev_result.intent in _ACTION_INTENTS
        and jev_result.confidence >= _threshold("CONFIDENCE_THRESHOLD", 0.7)
    ):
        routed = RoutedIntent(
            intent=jev_result.intent,
            classifier="jev",
            confidence=jev_result.confidence,
            fallback_used=False,
            jev_model=jev_result.model,
        )
        _log(routed, jev_result.p_max, jev_result.p_second, started)
        return routed

    intent = await _gemini_intent(text, history, provider)
    routed = RoutedIntent(
        intent=intent,
        classifier="gemini",
        confidence=jev_result.confidence,
        fallback_used=True,
        jev_model=jev_result.model,
    )
    _log(routed, jev_result.p_max, jev_result.p_second, started)
    return routed


_jev = None


def _get_jev():
    """One JevClassifier for the process. Tests may replace this."""
    global _jev
    if _jev is None:
        from .jev import JevClassifier

        _jev = JevClassifier()
    return _jev


async def _call_jev(text, history):
    """Call Jev unless its breaker is open. An open breaker does not call Jev."""
    from .reliability import call_dependency, jev_breaker

    return await call_dependency(
        jev_breaker(),
        lambda: _get_jev().classify(text, history),
    )


async def _gemini_intent(text, history, provider) -> Intent:
    from .parser import classify_with_llm

    return await classify_with_llm(text, history, provider=provider)


def _threshold(name: str, default: float) -> float:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    return float(raw)


def _group_choice(probabilities: dict) -> tuple[Intent, float] | None:
    """If app_help + unknown is high enough, pick the more likely of the two.

    A tie uses app_help. The reply step tries that handler first when unsure.
    """
    app_p = float(probabilities.get("app_help", 0.0))
    unknown_p = float(probabilities.get("unknown", 0.0))
    if app_p + unknown_p < _threshold("GROUP_THRESHOLD", 0.6):
        return None
    if app_p >= unknown_p:
        return Intent.app_help, app_p
    return Intent.unknown, unknown_p


def _log(routed: RoutedIntent, p_max, p_second, started: float) -> None:
    """One line. Never include the user text."""
    if p_max is None or p_second is None:
        ratio = "n/a"
    elif p_second == 0:
        ratio = "inf"
    else:
        ratio = f"{p_max / p_second:.3f}"
    latency_ms = int((time.perf_counter() - started) * 1000)
    logger.info(
        "classification classifier=%s intent=%s confidence=%s p_max=%s "
        "p_max_over_p_second=%s fallback_used=%s jev_model=%s latency_ms=%s",
        routed.classifier,
        routed.intent.value,
        routed.confidence,
        p_max,
        ratio,
        routed.fallback_used,
        routed.jev_model,
        latency_ms,
    )
