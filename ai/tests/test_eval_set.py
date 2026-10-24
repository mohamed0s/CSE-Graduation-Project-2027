"""Offline checks for eval/eval_set.csv. No network, no LLM."""

import csv
import importlib.util
import json
import sys
from pathlib import Path

CSV_PATH = Path(__file__).resolve().parent.parent / "eval" / "eval_set.csv"


def test_eval_set_history_column():
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    assert rows
    assert "history" in rows[0]
    ids = [row["id"] for row in rows]
    assert len(ids) == len(set(ids))
    for row in rows:
        raw = (row.get("history") or "").strip()
        if not raw:
            continue
        messages = json.loads(raw)
        assert isinstance(messages, list)
        for message in messages:
            assert message["role"] in {"user", "assistant"}
            assert isinstance(message["content"], str)


def test_eval_string_match_ignores_arabic_spelling_variants():
    path = Path(__file__).resolve().parent.parent / "scripts" / "run_eval.py"
    spec = importlib.util.spec_from_file_location("run_eval_match", path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    assert module._matches("اسنان", "أسنان")
    assert module._matches("للايجار", "للإيجار")
    assert module._matches("3000", 3000.0)
    assert not module._matches("3000", 3001)


def _load_run_eval():
    path = Path(__file__).resolve().parent.parent / "scripts" / "run_eval.py"
    spec = importlib.util.spec_from_file_location("run_eval_offline", path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def _run(coro):
    import asyncio

    return asyncio.run(coro)


def test_provider_error_is_counted_and_run_continues(capsys):
    module = _load_run_eval()
    seen = []

    async def fake_parse(sentence, history=None, intent=None, provider=None):
        seen.append(sentence)
        if sentence == "boom":
            from app.ai.errors import AIServiceError

            raise AIServiceError("provider failed")

        class IntentValue:
            value = "unknown"

        class Result:
            intent = IntentValue()
            fields = {}

        return Result()

    rows = [
        {"id": "1", "sentence": "ok-one", "intent": "unknown", "history": ""},
        {"id": "2", "sentence": "boom", "intent": "unknown", "history": ""},
        {"id": "3", "sentence": "ok-three", "intent": "unknown", "history": ""},
    ]
    code = _run(module.run_rows(rows, delay=0, parse=fake_parse))
    out = capsys.readouterr().out
    assert seen == ["ok-one", "boom", "ok-three"]
    assert out.count("RESULT  : ERROR (provider failed)") == 1
    assert "Traceback" not in out
    assert "TOTAL: 2 passed, 0 failed, 1 errors, 3 total" in out
    assert code == 1


def test_limit_and_offset_select_rows():
    module = _load_run_eval()
    rows = [{"id": str(i), "sentence": f"s{i}"} for i in range(1, 6)]
    assert [row["id"] for row in module.select_rows(rows, limit=2, offset=1)] == [
        "2",
        "3",
    ]
    assert [row["id"] for row in module.select_rows(rows, limit=None, offset=0)] == [
        "1",
        "2",
        "3",
        "4",
        "5",
    ]
    args = module.parse_args(["--limit", "2", "--offset", "1", "--delay", "0"])
    assert args.limit == 2
    assert args.offset == 1
    assert args.delay == 0
    assert module.parse_args([]).delay == 0
