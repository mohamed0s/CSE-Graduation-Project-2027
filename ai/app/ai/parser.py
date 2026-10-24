from __future__ import annotations

import json
import logging
import re
import unicodedata
from pathlib import Path
from typing import List, Optional

from dotenv import load_dotenv
from pydantic import ValidationError

from .base import LLMProvider, Message
from .errors import AIServiceError
from .schemas import (
    FIELD_QUESTIONS,
    REQUIRED_FIELDS,
    ExtractionResult,
    Intent,
    INTENT_FIELD_MODELS,
)

logger = logging.getLogger(__name__)

load_dotenv()


PROMPTS_DIR = Path(__file__).resolve().parent.parent.parent / "prompts"

_DIACRITICS = re.compile("[ً-ْـ]")
_ALEF_VARIANTS = re.compile("[أإآٱ]")

MAX_RETRIES = 2  # i.e. 1 initial attempt + up to 2 retries

# Guard note appended to every user turn: the user text is DATA, not orders.
_USER_TEXT_WRAP = "<user_text>\n{text}\n</user_text>"
# Strip these so a user cannot close the wrapper and inject instructions.
_USER_TEXT_TAG = re.compile(r"</?user_text>", re.IGNORECASE)


def normalize_arabic(text: str) -> str:
    """Remove tashkeel and unify alef / alif maqsura. Helper for later matching.

    The model is sent the original text, not this. ؤ and ئ are left as-is
    (they are different letters, not alef/yaa variants).
    """
    text = _DIACRITICS.sub("", text)
    text = _ALEF_VARIANTS.sub("ا", text)
    text = text.replace("ى", "ي")
    return unicodedata.normalize("NFC", text).strip()


_ARABIC_INDIC_DIGITS = str.maketrans("٠١٢٣٤٥٦٧٨٩", "0123456789")


def to_western_digits(text: str) -> str:
    """Convert Arabic-Indic digits ٠-٩ to Western 0-9. Helper for later matching."""
    return text.translate(_ARABIC_INDIC_DIGITS)


def _strip_user_text_tags(text: str) -> str:
    """Remove <user_text> wrappers (any case) before we add our own."""
    return _USER_TEXT_TAG.sub("", text)


def _user_turn(text: str) -> str:
    """Wrap the original user text. Only .strip(); no Arabic normalization."""
    clean = _strip_user_text_tags(text.strip())
    return _USER_TEXT_WRAP.format(text=clean)


def _sanitize_history(history: List[Message] | None) -> List[Message]:
    """Copy history. User turns are data; assistant turns stay plain text.

    User content is tag-stripped then wrapped once (_user_turn), so a break-out
    cannot close the wrapper. Assistant content is only tag-stripped. Does not
    mutate the caller. Retry nudges are appended later and are not wrapped.
    """
    cleaned: List[Message] = []
    for msg in history or []:
        content = msg.get("content", "")
        if isinstance(content, str) and msg.get("role") == "user":
            content = _user_turn(content)
        elif isinstance(content, str):
            content = _strip_user_text_tags(content)
        cleaned.append({**msg, "content": content})
    return cleaned


def _load_prompt(name: str) -> str:
    return (PROMPTS_DIR / name).read_text(encoding="utf-8")


def _extract_json(raw: str) -> dict:
    """Pull the first JSON object out of the model reply (fences allowed)."""
    raw = raw.strip()
    raw = re.sub(r"^```(json)?|```$", "", raw, flags=re.MULTILINE).strip()
    start, end = raw.find("{"), raw.rfind("}")
    if start == -1 or end == -1:
        raise ValueError("no JSON object found")
    data = json.loads(raw[start : end + 1])
    if not isinstance(data, dict):
        raise ValueError("JSON is not an object")
    return data


def _validate_fields(intent: Intent, data: dict) -> dict:
    """Validate with the intent's Pydantic model; drop unknown keys."""
    model = INTENT_FIELD_MODELS[intent]
    parsed = model.model_validate(data)
    return parsed.model_dump()


def _compute_missing(intent: Intent, fields: dict) -> List[str]:
    """Compute missing required fields IN CODE, from REQUIRED_FIELDS."""
    return [name for name in REQUIRED_FIELDS[intent] if not fields.get(name)]


def _log_provider_failure(operation: str, exc: BaseException, intent: str | None = None) -> None:
    """Log a provider failure. Never log the API key or the prompt text."""
    logger.error(
        "LLM provider failed during %s (intent=%s, error_type=%s)",
        operation,
        intent,
        type(exc).__name__,
    )


def _clarifying_question(missing: List[str]) -> str | None:
    """Fixed question for the first missing required field. No model call."""
    if not missing:
        return None
    return FIELD_QUESTIONS[missing[0]]


def _westernize_budget(data: dict) -> dict:
    """Arabic-Indic digits in a string budget, so Pydantic can parse the float.

    Other text fields are left as the model wrote them.
    """
    budget = data.get("budget")
    if isinstance(budget, str):
        data = dict(data)
        data["budget"] = to_western_digits(budget)
    return data


def _westernize_ids(fields: dict) -> dict:
    """Ids, quantities, and size. Location and names stay as written."""
    cleaned = dict(fields)
    for name in ("order_id", "quantity_or_time", "size"):
        value = cleaned.get(name)
        if isinstance(value, str):
            cleaned[name] = to_western_digits(value)
    return cleaned


async def extract(
    text: str,
    history: List[Message] | None,
    intent: Intent,
    provider: Optional[LLMProvider] = None,
) -> ExtractionResult:
    """Extract the fields of ONE known intent from `text`.

    Asks the provider for JSON with ONLY that intent's fields, validates
    with Pydantic, retries up to MAX_RETRIES times, then returns whatever
    it has. `missing_fields` is computed from REQUIRED_FIELDS in code. If
    any are missing, `clarifying_question` is the fixed question for the
    first one (no extra model call).
    """
    # app_help / unknown have no fields; don't spend a model call on {}.
    if not INTENT_FIELD_MODELS[intent].model_fields:
        return ExtractionResult(
            intent=intent,
            fields={},
            missing_fields=[],
            clarifying_question=None,
        )

    if provider is None:
        from . import get_provider  # local import to avoid circularity

        provider = get_provider()

    system = _load_prompt(f"extract_{intent.value}.txt")
    messages: List[Message] = _sanitize_history(history)
    messages.append({"role": "user", "content": _user_turn(text)})

    fields: dict = {}
    for attempt in range(1 + MAX_RETRIES):
        try:
            raw = await provider.complete(system, messages)
            data = _westernize_budget(_extract_json(raw))
            fields = _validate_fields(intent, data)
            break
        except (ValueError, ValidationError):
            # Bad JSON / schema only. Provider failures are not retried.
            if attempt == MAX_RETRIES:
                fields = {}  # give up; missing_fields will reflect reality
            else:
                # Ask the model to fix its output on the next attempt.
                messages.append(
                    {
                        "role": "user",
                        "content": (
                            "Return ONLY valid JSON with the allowed fields. "
                            "No extra text."
                        ),
                    }
                )
        except AIServiceError:
            raise
        except Exception as exc:
            _log_provider_failure("extract", exc, intent.value)
            raise AIServiceError("LLM provider failed during extraction") from exc

    fields = _westernize_ids(fields)
    missing = _compute_missing(intent, fields)

    return ExtractionResult(
        intent=intent,
        fields={k: v for k, v in fields.items() if v is not None},
        missing_fields=missing,
        clarifying_question=_clarifying_question(missing),
    )


async def classify_with_llm(
    text: str,
    history: List[Message] | None = None,
    provider: Optional[LLMProvider] = None,
) -> Intent:
    """TEMPORARY classifier until the router is added.

    Uses the main provider + prompts/classify.txt. Retries up to
    MAX_RETRIES times, then returns Intent.unknown.
    """
    if provider is None:
        from . import get_provider  # local import to avoid circularity

        provider = get_provider()

    system = _load_prompt("classify.txt")
    messages: List[Message] = _sanitize_history(history)
    messages.append({"role": "user", "content": _user_turn(text)})

    for attempt in range(1 + MAX_RETRIES):
        try:
            raw = await provider.complete(system, messages)
            intent_value = _extract_json(raw).get("intent")
            return Intent(intent_value)
        except (ValueError, ValidationError):
            if attempt < MAX_RETRIES:
                messages.append(
                    {
                        "role": "user",
                        "content": (
                            'Return ONLY valid JSON like {"intent": "..."}. '
                            "No extra text."
                        ),
                    }
                )
        except AIServiceError:
            raise
        except Exception as exc:
            _log_provider_failure("classify", exc)
            raise AIServiceError("LLM provider failed during classification") from exc

    return Intent.unknown


async def parse_request(
    text: str,
    history: List[Message] | None = None,
    intent: Optional[Intent] = None,
    provider: Optional[LLMProvider] = None,
) -> ExtractionResult:
    """Main entry point: classify (unless the router already decided),
    then extract the fields for that intent."""
    if provider is None:
        from . import get_provider  # local import to avoid circularity

        provider = get_provider()

    from .reliability import guard_llm

    # Same complete() contract. The LLM breaker counts failures on this object.
    provider = guard_llm(provider)

    routed = None
    if intent is None:
        from .router import classify as route_classify

        routed = await route_classify(text, history, provider=provider)
        intent = routed.intent
    result = await extract(text, history, intent, provider=provider)
    if routed is not None:
        result.classifier = routed.classifier
        result.classifier_confidence = routed.confidence
        result.fallback_used = routed.fallback_used
        result.jev_model = routed.jev_model
    if intent in (Intent.app_help, Intent.unknown):
        from .replies import compose_reply

        confidence = routed.confidence if routed is not None else None
        result.reply_text = await compose_reply(
            intent, text, list(history or []), confidence
        )
    return result
