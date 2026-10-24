"""Find eval sentences that also appear as prompt or Jev examples.

Offline. Does not call a provider. From the repo root or elsewhere:
    python scripts/check_leakage.py

Exit code 1 if any leak, 0 otherwise.
"""

from __future__ import annotations

import csv
import difflib
import json
import re
import sys
from pathlib import Path

# python scripts/<name>.py puts only scripts/ on sys.path. Add the repo root.
_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from app.ai.parser import normalize_arabic

CSV_PATH = _ROOT / "eval" / "eval_set.csv"
PROMPTS_DIR = _ROOT / "prompts"
CRITERIA_PATH = _ROOT / "app" / "ai" / "intent_criteria.py"

# Few-shot user turns. A bare "<user_text>" in the security note is not an example.
_USER_TURN = re.compile(
    r"^User:\s*<user_text>\s*(.*?)\s*</user_text>",
    re.IGNORECASE | re.MULTILINE | re.DOTALL,
)
# Example: "..." and Examples: "a", "b" — not the JSON field values below them.
_QUOTED = re.compile(r'"([^"\n]+)"')
_MIN_CONTAINS = 12
_SIMILARITY = 0.85


def normalize_text(text: str) -> str:
    """Arabic spelling variants, case, punctuation, and extra spaces."""
    text = normalize_arabic(text or "")
    text = text.lower()
    text = "".join(ch if ch.isalnum() or ch.isspace() else " " for ch in text)
    return re.sub(r"\s+", " ", text).strip()


def _rel(path: Path) -> str:
    return path.relative_to(_ROOT).as_posix()


def examples_from_prompt(text: str) -> list[str]:
    """User utterances in a prompt file, not instructions or JSON labels."""
    found = [match.strip() for match in _USER_TURN.findall(text)]
    for line in text.splitlines():
        # A one-line "User: ..." example, if a prompt ever uses that shape.
        if line.startswith("User:") and "<user_text>" not in line.lower():
            found.append(line.split(":", 1)[1].strip())
        # Inline Example: "..." lines. Skip other quotes (JSON field values).
        if "example" in line.lower():
            found.extend(part.strip() for part in _QUOTED.findall(line))
    return [part for part in found if part]


def examples_from_criteria(text: str) -> list[str]:
    """Quoted example utterances inside the Jev criteria strings."""
    return [part.strip() for part in _QUOTED.findall(text) if part.strip()]


def collect_examples() -> list[dict]:
    """One entry per file and normalized example text."""
    collected: list[dict] = []
    files = sorted(path for path in PROMPTS_DIR.iterdir() if path.is_file())
    files.append(CRITERIA_PATH)
    for path in files:
        raw = path.read_text(encoding="utf-8")
        if path == CRITERIA_PATH:
            pieces = examples_from_criteria(raw)
        else:
            pieces = examples_from_prompt(raw)
        seen: set[str] = set()
        for piece in pieces:
            normalized = normalize_text(piece)
            if not normalized or normalized in seen:
                continue
            seen.add(normalized)
            collected.append(
                {"file": _rel(path), "text": piece, "normalized": normalized}
            )
    return collected


def _history_user_texts(raw: str) -> list[str]:
    text = (raw or "").strip()
    if not text:
        return []
    try:
        messages = json.loads(text)
    except json.JSONDecodeError:
        return []
    if not isinstance(messages, list):
        return []
    contents = []
    for message in messages:
        if not isinstance(message, dict) or message.get("role") != "user":
            continue
        content = message.get("content")
        if isinstance(content, str) and content.strip():
            contents.append(content.strip())
    return contents


def eval_items() -> list[dict]:
    """Sentence column, plus earlier user turns from history.

    A row with history is a short follow-up: its sentence matches only on
    exact equality. Earlier user turns are full requests and use every rule.
    """
    items = []
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            history = (row.get("history") or "").strip()
            items.append(
                {
                    "id": row.get("id", "?"),
                    "split": row.get("split", ""),
                    "source": "sentence",
                    "text": row.get("sentence", ""),
                    "followup": bool(history),
                }
            )
            for content in _history_user_texts(history):
                items.append(
                    {
                        "id": row.get("id", "?"),
                        "split": row.get("split", ""),
                        "source": "history",
                        "text": content,
                        "followup": False,
                    }
                )
    return items


def is_leak(left: str, right: str, followup: bool) -> bool:
    if not left or not right:
        return False
    if left == right:
        return True
    if followup:
        return False
    shorter, longer = (left, right) if len(left) <= len(right) else (right, left)
    if len(shorter) >= _MIN_CONTAINS and shorter in longer:
        return True
    return difflib.SequenceMatcher(None, left, right).ratio() >= _SIMILARITY


def find_leaks() -> list[dict]:
    examples = collect_examples()
    leaks = []
    for item in eval_items():
        normalized = normalize_text(item["text"])
        for example in examples:
            if not is_leak(normalized, example["normalized"], item["followup"]):
                continue
            leaks.append(
                {
                    "id": item["id"],
                    "split": item["split"],
                    "source": item["source"],
                    "sentence": item["text"],
                    "file": example["file"],
                    "match": example["text"],
                }
            )
    leaks.sort(key=lambda leak: (str(leak["id"]), leak["source"], leak["file"], leak["match"]))
    return leaks


def format_leak(leak: dict) -> str:
    return (
        f"id={leak['id']} split={leak['split']} source={leak['source']} "
        f"file={leak['file']}\n"
        f"sentence: {leak['sentence']}\n"
        f"match: {leak['match']}"
    )


def configure_stdio() -> None:
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is None:
            continue
        try:
            reconfigure(encoding="utf-8")
        except (OSError, ValueError):
            pass


def main() -> int:
    configure_stdio()
    leaks = find_leaks()
    for leak in leaks:
        print(format_leak(leak))
        print("-" * 60)
    print(f"LEAKS: {len(leaks)}")
    return 1 if leaks else 0


if __name__ == "__main__":
    sys.exit(main())
