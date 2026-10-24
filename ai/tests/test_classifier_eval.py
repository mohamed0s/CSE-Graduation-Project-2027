"""Offline metric tests. A fake classifier supplies scores; no network."""

import importlib.util
import sys
from pathlib import Path

from app.ai.schemas import Intent


def _load():
    path = Path(__file__).resolve().parent.parent / "scripts" / "run_classifier_eval.py"
    spec = importlib.util.spec_from_file_location("run_classifier_eval", path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def _row(module, expected, predicted, confidence=None, p_max=None, p_second=None, row_id="1", sentence="s"):
    return module.ScoredRow(
        id=row_id,
        sentence=sentence,
        expected=expected,
        predicted=predicted,
        confidence=confidence,
        p_max=p_max,
        p_second=p_second,
        model="jev-1.13.0-test",
    )


def test_accuracy_and_confusion_matrix():
    module = _load()
    rows = [
        _row(module, "search_service", "search_service", row_id="1"),
        _row(module, "search_service", "unknown", row_id="2"),
        _row(module, "place_order", "place_order", row_id="3"),
    ]
    assert module.accuracy(rows) == 2 / 3
    per_intent = module.accuracy_per_intent(rows)
    assert per_intent["search_service"] == (1, 2)
    assert per_intent["place_order"] == (1, 1)
    matrix = module.confusion_matrix(rows)
    assert matrix[("search_service", "unknown")] == 1
    assert matrix[("place_order", "place_order")] == 1


def test_confidence_buckets_and_confident_wrong():
    module = _load()
    samples = [0.29, 0.3, 0.49, 0.5, 0.7, 0.89, 0.9]
    expected_names = [
        "<0.3",
        "0.3-0.5",
        "0.3-0.5",
        "0.5-0.7",
        "0.7-0.9",
        "0.7-0.9",
        ">=0.9",
    ]
    rows = [
        _row(module, "search_service", "unknown", confidence=0.7, row_id="a"),
        _row(module, "search_service", "unknown", confidence=0.9, row_id="b"),
        _row(module, "search_service", "search_service", confidence=0.89, row_id="c"),
        _row(module, "search_service", "unknown", confidence=0.69, row_id="d"),
    ]
    assert [module.confidence_bucket(score) for score in samples] == expected_names
    buckets = module.accuracy_per_bucket(rows)
    assert buckets["0.7-0.9"] == (1, 2)
    assert buckets[">=0.9"] == (0, 1)
    assert module.confident_wrong_count(rows) == 2


def test_threshold_sweep_and_lowest_95():
    module = _load()
    rows = [
        _row(module, "a", "b", confidence=0.4, p_max=0.4, p_second=0.4, row_id="1"),
        _row(module, "a", "a", confidence=0.6, p_max=0.6, p_second=0.3, row_id="2"),
        _row(module, "a", "a", confidence=0.8, p_max=0.8, p_second=0.2, row_id="3"),
        _row(module, "a", "a", confidence=0.9, p_max=0.9, p_second=0.0, row_id="4"),
    ]
    acc, fallback, accepted = module.accepted_stats(
        rows, lambda row: row.confidence, 0.6
    )
    assert accepted == 3
    assert acc == 1.0
    assert fallback == 0.25
    assert module.lowest_threshold(rows, lambda row: row.confidence) == 0.6
    # Accepting everyone is only 75%, so the ratio threshold is not 0.
    assert module.lowest_threshold(rows, module.ratio) == 2.0
    # p_second 0 is infinite separation and stays accepted at a high cut.
    high_acc, high_fallback, high_n = module.accepted_stats(rows, module.ratio, 10)
    assert high_n == 1
    assert high_acc == 1.0
    assert high_fallback == 0.75
    all_correct = [
        _row(module, "a", "a", confidence=0.2, row_id="9"),
        _row(module, "a", "a", confidence=0.4, row_id="10"),
    ]
    assert module.lowest_threshold(all_correct, lambda row: row.confidence) == 0.0
    only_wrong = [_row(module, "a", "b", confidence=0.99, row_id="11")]
    assert module.lowest_threshold(only_wrong, lambda row: row.confidence) is None


def test_group_metric_and_small_set_warning():
    module = _load()
    rows = [
        _row(module, "unknown", "app_help", row_id="1", sentence="hi"),
        _row(module, "app_help", "app_help", row_id="2"),
        _row(module, "search_service", "unknown", row_id="3", sentence="سباك"),
        _row(module, "place_order", "place_order", row_id="4"),
    ]
    assert module.group_confusion_count(rows) == 1
    assert module.grouped_accuracy(rows) == 0.75
    assert module.accuracy(rows) == 0.5
    warning = module.small_set_warning(16)
    assert warning is not None
    assert "fewer than 50" in warning
    assert module.small_set_warning(50) is None
    report = module.format_report(rows, classifier="jev", skipped=0)
    assert "WARNING:" in report
    assert "jev-1.13.0-test" in report
    assert "1 | unknown | app_help" in report
    assert "Confident wrong" in report


def test_fake_classifier_scores_history_and_skips_bad_json():
    module = _load()

    async def fake_classify(sentence, history):
        assert history == [{"role": "user", "content": "محتاج دكتور"}]
        assert sentence == "المعادي"
        return "search_service", 0.91, 0.8, 0.1, "jev-test"

    rows = [
        {
            "id": "11",
            "sentence": "المعادي",
            "intent": "search_service",
            "history": '[{"role": "user", "content": "محتاج دكتور"}]',
        },
        {"id": "12", "sentence": "broken", "intent": "unknown", "history": "{not json"},
    ]
    scored, skipped, latencies = _run(module.evaluate(rows, fake_classify, delay=0))
    assert skipped == 1
    assert len(latencies) == 1
    assert len(scored) == 1
    assert scored[0].predicted == "search_service"
    assert scored[0].correct
    assert scored[0].model == "jev-test"
    assert module.default_delay("jev") == 0
    assert module.default_delay("gemini") == 6
    assert {item.value for item in Intent} <= set(module._INTENT_ORDER)


def test_fake_classifier_latency_excludes_delay():
    module = _load()

    async def fake_classify(sentence, history):
        return "unknown", None, None, None, None

    rows = [
        {"id": "1", "sentence": "one", "intent": "unknown", "history": ""},
        {"id": "2", "sentence": "two", "intent": "unknown", "history": ""},
    ]
    scored, skipped, latencies = _run(module.evaluate(rows, fake_classify, delay=1))
    assert skipped == 0
    assert len(scored) == 2
    assert len(latencies) == 2
    # The 1s pause between rows must not be part of either classify time.
    assert all(ms < 500 for ms in latencies)
    mean_ms, p95_ms = module.latency_stats([10, 20, 30, 40, 100])
    assert mean_ms == 40
    assert p95_ms == 100
    assert module.latency_stats([]) == (None, None)
    for name in ("jev", "gemini"):
        report = module.format_report(
            scored, classifier=name, skipped=0, latencies_ms=latencies
        )
        assert report.strip().endswith("ms")
        assert "Mean latency:" in report
        assert "p95 latency:" in report
        if name == "jev":
            assert report.index("Jev model ID(s):") < report.index("Mean latency:")


def _run(coro):
    import asyncio

    return asyncio.run(coro)
