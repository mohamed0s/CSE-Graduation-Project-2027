"""Score eval/eval_set.csv with the real provider (needs a key in .env).

Not a unit test. From the repo root or any other working directory:
    python scripts/run_eval.py
    python scripts/run_eval.py --offset 20 --limit 20 --delay 6
    python <repo>/scripts/run_eval.py
"""

import argparse
import asyncio
import csv
import json
import sys
from pathlib import Path

# python scripts/<name>.py puts only scripts/ on sys.path. Add the repo root.
_ROOT = Path(__file__).resolve().parent.parent
if str(_ROOT) not in sys.path:
    sys.path.insert(0, str(_ROOT))

from app.ai.errors import AIServiceError
from app.ai.parser import normalize_arabic, parse_request

CSV_PATH = Path(__file__).resolve().parent.parent / "eval" / "eval_set.csv"

# Empty cells are not checked. budget is compared as a number.
FIELD_COLUMNS = (
    "category",
    "location",
    "budget",
    "item_type",
    "size",
    "space_type",
    "goal",
    "item",
    "provider",
    "quantity_or_time",
    "order_id",
)


def parse_history(raw: str, row_id: str):
    """Return (history, error). Empty cell means no history."""
    text = (raw or "").strip()
    if not text:
        return None, None
    try:
        return json.loads(text), None
    except json.JSONDecodeError as exc:
        return None, f"row {row_id}: invalid history JSON ({exc})"


def _matches(expected: str, actual) -> bool:
    if actual is None:
        return False
    if expected.replace(".", "", 1).isdigit():
        try:
            return float(expected) == float(actual)
        except (TypeError, ValueError):
            return False
    # Spelling variants (اسنان / أسنان, للايجار / للإيجار) are the same value.
    return normalize_arabic(str(actual)) == normalize_arabic(expected)


def parse_args(argv=None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Score eval/eval_set.csv.")
    parser.add_argument(
        "--delay",
        type=float,
        default=0,
        help="Seconds to wait between rows (default 0)",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Run only the first N rows after --offset",
    )
    parser.add_argument(
        "--offset",
        type=int,
        default=0,
        help="Skip the first N rows",
    )
    return parser.parse_args(argv)


def select_rows(rows, limit: int | None, offset: int):
    """Skip `offset` rows, then keep at most `limit` rows."""
    chosen = list(rows)[offset:]
    if limit is not None:
        chosen = chosen[:limit]
    return chosen


def configure_stdio() -> None:
    """UTF-8 stdout/stderr so piping Arabic in PowerShell does not crash."""
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure is None:
            continue
        try:
            reconfigure(encoding="utf-8")
        except (OSError, ValueError):
            pass


async def run_rows(rows, delay: float = 0, parse=None) -> int:
    """Score `rows`. A provider failure is an error, not a traceback."""
    if parse is None:
        parse = parse_request
    passed = failed = errors = 0
    for index, row in enumerate(rows):
        if index > 0 and delay > 0:
            await asyncio.sleep(delay)
        row_id = row.get("id", "?")
        history, error = parse_history(row.get("history", ""), row_id)
        if error:
            # Bad history must not abort the rest of the file.
            print(error)
            print("RESULT  : FAIL")
            print("-" * 60)
            failed += 1
            continue
        try:
            result = await parse(row["sentence"], history)
        except AIServiceError:
            print("INPUT   :", row["sentence"])
            print("RESULT  : ERROR (provider failed)")
            print("-" * 60)
            errors += 1
            continue
        ok = result.intent.value == row.get("intent")
        for name in FIELD_COLUMNS:
            expected = (row.get(name) or "").strip()
            if expected and not _matches(expected, result.fields.get(name)):
                ok = False
        passed += ok
        failed += not ok
        print("INPUT   :", row["sentence"])
        print("INTENT  :", result.intent.value, f"(expected {row.get('intent')})")
        print("FIELDS  :", result.fields)
        print("RESULT  :", "PASS" if ok else "FAIL")
        print("-" * 60)
    print(
        f"TOTAL: {passed} passed, {failed} failed, {errors} errors, {len(rows)} total"
    )
    return 0 if failed == 0 and errors == 0 else 1


def load_rows():
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


async def main(argv=None) -> int:
    configure_stdio()
    args = parse_args(argv)
    if args.limit is not None and args.limit < 0:
        print("--limit must be 0 or more", file=sys.stderr)
        return 2
    if args.offset < 0:
        print("--offset must be 0 or more", file=sys.stderr)
        return 2
    chosen = select_rows(load_rows(), args.limit, args.offset)
    return await run_rows(chosen, args.delay)


if __name__ == "__main__":
    configure_stdio()
    sys.exit(asyncio.run(main()))
