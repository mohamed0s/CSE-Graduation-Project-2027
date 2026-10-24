"""Choice criteria for Jev. Wording lives here so it is easy to tune.

Meanings and boundaries match prompts/classify.txt. Do not edit that file
from here; the classifier prompt test still checks it.
"""

# Classify the LAST user message. A short answer keeps the earlier intent.
INTENT_INSTRUCTIONS = (
    "Classify the LAST user message into exactly one intent for a local-services "
    "app in Egypt. If the latest message only answers the assistant's question "
    "(a place, a number, a name), return the intent of the EARLIER user request, "
    "not the intent the answer would suggest on its own. If the latest message "
    "clearly starts a different request, classify the latest message. If there is "
    "no earlier context, classify the last message alone. "
    "place_order only when the user uses an explicit ordering verb for a specific "
    "item; just looking, or asking about availability or delivery, is search_service. "
    "budget_recommendation only when the user GIVES a budget; a price estimate "
    '("بكام", "هيتكلف كام") is unknown. '
    "space_idea only when the user OWNS an empty space and asks what project suits "
    "it; interior design or decoration is unknown. "
    'A bare order number answering "what is the order number?" is track_order.'
)

# Keys must be the Intent values. Each description has 2-3 short examples.
INTENT_CRITERIA: dict[str, str] = {
    "search_service": (
        "The user wants to FIND a provider, place, or professional. "
        "Also use this when they are only looking, or asking about availability "
        "or delivery, with no explicit order. "
        "Not this intent when the earlier request already stated a budget and the "
        "latest message only adds a location. "
        'Examples: "عايز سباك في المعادي", "3ayez lab t7aleel fel matarya", '
        '"فيه كشري التحرير بيوصّل؟".'
    ),
    "budget_recommendation": (
        "The user GIVES a budget and wants the best-fitting places or options "
        "recommended for that amount. It is NOT a price estimate. "
        "If the earlier request stated a budget and the latest message only adds "
        "a location, it is still budget_recommendation. "
        'Examples: "معي 900 جنيه عايزة تذاكر سينما", '
        '"120 geneh bas eddini workshop resm", "ميزانيتي 8000 جنيه شقة في مدينة نصر".'
    ),
    "space_idea": (
        "The user OWNS an empty space (shop, apartment, garage, land) and asks "
        "what to do with it or which project suits it. It is NOT interior design. "
        'Examples: "عندي محل فاضي أعمل فيه إيه", "3andy garage fady a3mel feh eh", '
        '"ورثت أرض فاضية ينفع عليها إيه".'
    ),
    "place_order": (
        "The user uses an explicit ordering verb (اطلبلي, ابعتلي, عايز أطلب, "
        "3abny, a3mly) for a specific item. Just looking is not this intent. "
        'Examples: "اطلبلي صينية كنافة من كنافة الست", "3abny 2 pizza men Pizza Hut", '
        '"ابعتلي 2 سندوتش فول".'
    ),
    "track_order": (
        "The user wants the status of an order they placed. A bare order number "
        'that answers "what is the order number?" is also this intent. '
        'Examples: "طلبي رقم 1234 وصل فين", "حالة الطلبية إيه", "4521".'
    ),
    "app_help": (
        "The user asks how the app works or for support. "
        'Examples: "إزاي أدفع بالبطاقة", "ezay astakhdem el app", '
        '"ايه هو Finda واستخدمه ازاي".'
    ),
    "unknown": (
        "Greetings, chit-chat, unrelated talk, a price estimate, or interior "
        "design / decoration. Not a short follow-up that continues an earlier "
        "request. "
        'Examples: "هاي اخبارك ايه", "تجديد المطبخ هيتكلف كام", '
        '"عايز أفكار ديكور لأوضة النوم".'
    ),
}
