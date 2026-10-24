from __future__ import annotations

from enum import Enum
from typing import Dict, List, Optional, Type

from pydantic import BaseModel, ConfigDict, Field


class Intent(str, Enum):
    """What the (future) router decides the user wants.

    Step 1b: the parser works with a given intent; classification here is
    only a temporary LLM fallback until the router is added.
    """

    search_service = "search_service"
    budget_recommendation = "budget_recommendation"
    space_idea = "space_idea"
    place_order = "place_order"
    track_order = "track_order"
    app_help = "app_help"
    unknown = "unknown"


# ---------------------------------------------------------------------------
# Per-intent field models (all fields optional; types are strings/numbers).
# ---------------------------------------------------------------------------


class SearchServiceFields(BaseModel):
    # Numbers in JSON (e.g. a code) become strings instead of failing validation.
    model_config = ConfigDict(coerce_numbers_to_str=True)

    category: Optional[str] = None
    location: Optional[str] = None


class BudgetRecommendationFields(BaseModel):
    # String fields accept numbers; budget stays a float.
    model_config = ConfigDict(coerce_numbers_to_str=True)

    item_type: Optional[str] = None
    budget: Optional[float] = None
    location: Optional[str] = None
    size: Optional[str] = None


class SpaceIdeaFields(BaseModel):
    model_config = ConfigDict(coerce_numbers_to_str=True)

    space_type: Optional[str] = None
    size: Optional[str] = None
    location: Optional[str] = None
    budget: Optional[float] = None
    goal: Optional[str] = None


class PlaceOrderFields(BaseModel):
    model_config = ConfigDict(coerce_numbers_to_str=True)

    item: Optional[str] = None
    provider: Optional[str] = None
    quantity_or_time: Optional[str] = None


class TrackOrderFields(BaseModel):
    model_config = ConfigDict(coerce_numbers_to_str=True)

    order_id: Optional[str] = None


class AppHelpFields(BaseModel):
    pass


# Which Pydantic model validates the fields of each intent.
INTENT_FIELD_MODELS: Dict[Intent, Type[BaseModel]] = {
    Intent.search_service: SearchServiceFields,
    Intent.budget_recommendation: BudgetRecommendationFields,
    Intent.space_idea: SpaceIdeaFields,
    Intent.place_order: PlaceOrderFields,
    Intent.track_order: TrackOrderFields,
    Intent.app_help: AppHelpFields,
    Intent.unknown: AppHelpFields,
}

# Fields the parser MUST have per intent. `missing_fields` is computed in
# code from this dict (never trusted from the LLM output).
REQUIRED_FIELDS: Dict[Intent, List[str]] = {
    Intent.search_service: ["category", "location"],
    Intent.budget_recommendation: ["item_type", "budget", "location"],
    Intent.space_idea: ["space_type", "location", "budget", "goal"],
    Intent.place_order: ["item", "provider"],
    Intent.track_order: [],
    Intent.app_help: [],
    Intent.unknown: [],
}

# One short Egyptian-Arabic question per field. The parser asks the question
# for the first missing required field. No model call.
FIELD_QUESTIONS: Dict[str, str] = {
    "location": "في أنهي منطقة؟",
    "budget": "ميزانيتك في حدود كام؟",
    "category": "محتاج أنهي خدمة بالظبط؟",
    "item_type": "بتدوّر على إيه بالظبط؟",
    "provider": "من أنهي مكان؟",
    "item": "عايز تطلب إيه؟",
    "space_type": "المكان ده إيه نوعه؟",
    "goal": "عايز تستفيد منه إزاي؟",
    "size": "المساحة كام متر؟",
    "quantity_or_time": "الكمية أو المعاد إيه؟",
    "order_id": "رقم الطلب إيه؟",
}


class ExtractionResult(BaseModel):
    """Final parser output for one user message."""

    intent: Intent
    fields: Dict[str, Optional[str | float]] = Field(default_factory=dict)
    missing_fields: List[str] = Field(default_factory=list)
    clarifying_question: Optional[str] = None
    # Set by the router. Defaults keep older callers working.
    classifier: Optional[str] = None
    classifier_confidence: Optional[float] = None
    fallback_used: bool = False
    jev_model: Optional[str] = None
    # Set for app_help and unknown. Other intents leave it empty.
    reply_text: Optional[str] = None
