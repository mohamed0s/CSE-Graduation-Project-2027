"""Evaluate only the intent classifier on eval/eval_set.csv.

No extraction and no fallback. A real run needs a key in .env.

Usage, from the repo root or any other working directory:
    python scripts/run_classifier_eval.py --classifier jev
    python scripts/run_classifier_eval.py --classifier gemini --split dev
    python <repo>/scripts/run_classifier_eval.py --classifier jev

History is parsed the same way as scripts/run_eval.py. Invalid history is
printed and skipped; it is not a predicted intent.
"""

from __future__ import annotations

import argparse
import asyncio
import math
import sys
import time
from dataclasses import dataclass
from pathlib import Path

# python scripts/<name>.py puts only scripts/ on sys.path. Add the repo root
# so `app` imports, and keep scripts/ so the sibling run_eval import works.
_ROOT = Path(__file__).resolve().parent.parent
_SCRIPTS = Path(__file__).resolve().parent
for _path in (_ROOT, _SCRIPTS):
    _text = str(_path)
    if _text not in sys.path:
        sys.path.insert(0, _text)

from run_eval import CSV_PATH, parse_history  # noqa: E402

from app.ai.schemas import Intent  # noqa: E402

# unknown and app_help are one group for the extra accuracy line.
_GROUP = frozenset({"unknown", "app_help"})
_BUCKETS = ("<0.3", "0.3-0.5", "0.5-0.7", "0.7-0.9", ">=0.9")
# Printed sweep. The lowest 95% threshold is computed from the scores themselves.
_PROB_GRID = tuple(i / 20 for i in range(0, 20))
_RATIO_GRID = (1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0, 8.0, 10.0)
_INTENT_ORDER = [item.value for item in Intent]


@dataclass
class ScoredRow:
    """One classifier decision. Gemini has no calibrated scores."""

    id: str
    sentence: str
    expected: str
    predicted: str
    confidence: float | None = None
    p_max: float | None = None
    p_second: float | None = None
    model: str | None = None

    @property
    def correct(self) -> bool:
        return self.expected == self.predicted


def accuracy(rows: list[ScoredRow]) -> float | None:
    """Correct / n. None when there are no rows."""
    if not rows:
        return None
    return sum(row.correct for row in rows) / len(rows)


def accuracy_per_intent(rows: list[ScoredRow]) -> dict[str, tuple[int, int]]:
    """(correct, total) for each expected intent that appears."""
    totals: dict[str, int] = {}
    correct: dict[str, int] = {}
    for row in rows:
        totals[row.expected] = totals.get(row.expected, 0) + 1
        if row.correct:
            correct[row.expected] = correct.get(row.expected, 0) + 1
    ordered = [name for name in _labels(rows) if name in totals]
    return {name: (correct.get(name, 0), totals[name]) for name in ordered}


def confusion_matrix(rows: list[ScoredRow]) -> dict[tuple[str, str], int]:
    """Counts keyed by (expected, predicted)."""
    counts: dict[tuple[str, str], int] = {}
    for row in rows:
        key = (row.expected, row.predicted)
        counts[key] = counts.get(key, 0) + 1
    return counts


def confidence_bucket(confidence: float) -> str:
    """Bucket label. Cuts are 0.3, 0.5, 0.7, 0.9; the upper edge is exclusive."""
    if confidence < 0.3:
        return "<0.3"
    if confidence < 0.5:
        return "0.3-0.5"
    if confidence < 0.7:
        return "0.5-0.7"
    if confidence < 0.9:
        return "0.7-0.9"
    return ">=0.9"


def accuracy_per_bucket(rows: list[ScoredRow]) -> dict[str, tuple[int, int]]:
    """(correct, total) in each confidence bucket. Rows without confidence are skipped."""
    totals = {name: 0 for name in _BUCKETS}
    correct = {name: 0 for name in _BUCKETS}
    for row in rows:
        if row.confidence is None:
            continue
        name = confidence_bucket(row.confidence)
        totals[name] += 1
        if row.correct:
            correct[name] += 1
    return {name: (correct[name], totals[name]) for name in _BUCKETS}


def confident_wrong_count(rows: list[ScoredRow], threshold: float = 0.7) -> int:
    """Wrong rows whose confidence is at least `threshold`."""
    return sum(
        1
        for row in rows
        if not row.correct
        and row.confidence is not None
        and row.confidence >= threshold
    )


def group_confusion_count(rows: list[ScoredRow]) -> int:
    """Wrong rows that only swap unknown and app_help."""
    return sum(1 for row in rows if _inside_group(row) and not row.correct)


def grouped_accuracy(rows: list[ScoredRow]) -> float | None:
    """Accuracy if unknown/app_help confusion counts as correct."""
    if not rows:
        return None
    hits = sum(1 for row in rows if row.correct or _inside_group(row))
    return hits / len(rows)


def ratio(row: ScoredRow) -> float | None:
    """p_max / p_second. Infinite when p_second is 0 and p_max is set."""
    if row.p_max is None or row.p_second is None:
        return None
    if row.p_second == 0:
        return float("inf")
    return row.p_max / row.p_second


def accepted_stats(
    rows: list[ScoredRow],
    score_of,
    threshold: float,
) -> tuple[float | None, float, int]:
    """Accepted-row accuracy, fallback share, and how many rows are accepted.

    A row falls back to Gemini when its score is missing or below `threshold`.
    """
    if not rows:
        return None, 0.0, 0
    accepted = [
        row
        for row in rows
        if (score := score_of(row)) is not None and score >= threshold
    ]
    fallback_share = (len(rows) - len(accepted)) / len(rows)
    return accuracy(accepted), fallback_share, len(accepted)


def lowest_threshold(rows: list[ScoredRow], score_of) -> float | None:
    """Smallest threshold whose accepted rows are at least 95% correct.

    0 is used when accepting every scored row already meets 95%. None when
    no threshold does, including keeping only the highest score.
    """
    scored = [(score_of(row), row.correct) for row in rows if score_of(row) is not None]
    if not scored:
        return None
    if sum(ok for _, ok in scored) / len(scored) >= 0.95:
        return 0.0
    candidates = sorted({score for score, _ in scored})
    best: float | None = None
    for threshold in candidates:
        accepted = [(score, ok) for score, ok in scored if score >= threshold]
        if accepted and sum(ok for _, ok in accepted) / len(accepted) >= 0.95:
            best = threshold
            break
    return best


def latency_stats(samples_ms: list[float]) -> tuple[float | None, float | None]:
    """Mean and nearest-rank p95, in ms. None when no classify call was timed."""
    if not samples_ms:
        return None, None
    ordered = sorted(samples_ms)
    mean = sum(ordered) / len(ordered)
    # Smallest sample at or above the 95th percentile.
    index = math.ceil(0.95 * len(ordered)) - 1
    index = min(max(index, 0), len(ordered) - 1)
    return mean, ordered[index]


def small_set_warning(n: int) -> str | None:
    if n < 50:
        return (
            f"WARNING: only {n} rows (fewer than 50). "
            "Treat these metrics as a rough check, not a stable estimate."
        )
    return None


def default_delay(classifier: str) -> float:
    """Jev has no free-tier daily quota. Gemini does, so wait 6s."""
    return 0.0 if classifier == "jev" else 6.0


def _inside_group(row: ScoredRow) -> bool:
    return row.expected in _GROUP and row.predicted in _GROUP


def _labels(rows: list[ScoredRow], extra: dict | None = None) -> list[str]:
    seen = set(_INTENT_ORDER)
    names = list(_INTENT_ORDER)
    for row in rows:
        for label in (row.expected, row.predicted):
            if label not in seen:
                seen.add(label)
                names.append(label)
    if extra:
        for label in extra:
            if label not in seen:
                seen.add(label)
                names.append(label)
    return names


def _fmt_ms(value: float | None) -> str:
    if value is None:
        return "n/a"
    return f"{value:.1f} ms"


def _pct(value: float | None) -> str:
    if value is None:
        return "n/a"
    return f"{value * 100:.1f}%"


def _fmt_threshold(value: float | None) -> str:
    if value is None:
        return "none"
    if value == float("inf"):
        return "inf"
    return f"{value:.4g}"


def format_report(
    rows: list[ScoredRow],
    *,
    classifier: str,
    skipped: int,
    latencies_ms: list[float] | None = None,
) -> str:
    """Text report. Jev-only sections need confidence, p_max, and p_second."""
    lines: list[str] = []
    warning = small_set_warning(len(rows))
    if warning:
        lines.append(warning)
    if skipped:
        lines.append(f"Skipped rows (bad history or classifier error): {skipped}")
    overall = accuracy(rows)
    correct = sum(row.correct for row in rows)
    lines.append(f"Classifier: {classifier}")
    lines.append(f"Overall accuracy: {correct}/{len(rows)} ({_pct(overall)})")
    lines.append("")
    lines.append("Accuracy per intent (expected label):")
    for name, (hits, total) in accuracy_per_intent(rows).items():
        acc = hits / total if total else None
        lines.append(f"  {name}: {hits}/{total} ({_pct(acc)})")
    lines.append("")
    lines.append("Confusion matrix (rows = expected, columns = predicted):")
    labels = _labels(rows)
    header = "expected\\predicted".ljust(28) + "".join(label[:12].rjust(13) for label in labels)
    lines.append(header)
    matrix = confusion_matrix(rows)
    for expected in labels:
        cells = "".join(str(matrix.get((expected, predicted), 0)).rjust(13) for predicted in labels)
        lines.append(expected.ljust(28) + cells)
    wrong = [row for row in rows if not row.correct]
    lines.append("")
    lines.append(f"Wrong rows: {len(wrong)}")
    lines.append("id | expected | predicted | confidence | sentence")
    for row in wrong:
        confidence = "-" if row.confidence is None else f"{row.confidence:.3f}"
        lines.append(
            f"{row.id} | {row.expected} | {row.predicted} | {confidence} | {row.sentence}"
        )
    inside = group_confusion_count(rows)
    grouped = grouped_accuracy(rows)
    grouped_hits = sum(1 for row in rows if row.correct or _inside_group(row))
    lines.append("")
    lines.append(
        "unknown/app_help group: "
        f"{inside} wrong row(s) are only confusion inside that group."
    )
    lines.append(
        "Accuracy if that group counts as correct: "
        f"{grouped_hits}/{len(rows)} ({_pct(grouped)})"
    )
    if classifier == "jev":
        models = sorted({row.model for row in rows if row.model})
        lines.append("")
        if models:
            lines.append("Jev model ID(s): " + ", ".join(models))
        else:
            lines.append("Jev model ID(s): (none seen)")
        lines.append("")
        lines.append("Accuracy per confidence bucket:")
        for name, (hits, total) in accuracy_per_bucket(rows).items():
            acc = hits / total if total else None
            lines.append(f"  {name}: {hits}/{total} ({_pct(acc)})")
        lines.append(
            "Confident wrong (wrong and confidence >= 0.7): "
            f"{confident_wrong_count(rows)}"
        )
        lines.append("")
        _append_sweep(lines, rows, "confidence", lambda row: row.confidence, _PROB_GRID)
        _append_sweep(lines, rows, "p_max", lambda row: row.p_max, _PROB_GRID)
        _append_sweep(lines, rows, "p_max/p_second", ratio, _RATIO_GRID)
    if latencies_ms is not None:
        mean_ms, p95_ms = latency_stats(latencies_ms)
        lines.append("")
        lines.append(f"Mean latency: {_fmt_ms(mean_ms)}")
        lines.append(f"p95 latency: {_fmt_ms(p95_ms)}")
    return "\n".join(lines)


def _append_sweep(lines: list[str], rows: list[ScoredRow], name: str, score_of, grid) -> None:
    lines.append(f"Threshold sweep on {name} (accepted = score >= t; the rest would fall back to Gemini):")
    for threshold in grid:
        acc, fallback, accepted = accepted_stats(rows, score_of, threshold)
        lines.append(
            f"  t={_fmt_threshold(threshold)}  accepted={accepted}/{len(rows)}  "
            f"accuracy={_pct(acc)}  fallback={_pct(fallback)}"
        )
    lines.append(
        f"Lowest {name} threshold with accepted-row accuracy >= 95%: "
        f"{_fmt_threshold(lowest_threshold(rows, score_of))}"
    )
    lines.append("")


async def _classify_jev(text: str, history):
    from app.ai.jev import JevClassifier

    if not hasattr(_classify_jev, "classifier"):
        _classify_jev.classifier = JevClassifier()
    result = await _classify_jev.classifier.classify(text, history)
    return (
        result.intent.value,
        result.confidence,
        result.p_max,
        result.p_second,
        result.model,
    )


async def _classify_gemini(text: str, history):
    from app.ai.parser import classify_with_llm

    intent = await classify_with_llm(text, history)
    return intent.value, None, None, None, None


async def evaluate(
    rows: list[dict], classify, delay: float
) -> tuple[list[ScoredRow], int, list[float]]:
    """Run `classify(sentence, history)` only. No extraction.

    Each classify call is timed with perf_counter. The delay between rows
    is not included.
    """
    scored: list[ScoredRow] = []
    skipped = 0
    latencies_ms: list[float] = []
    for index, row in enumerate(rows):
        if index and delay > 0:
            await asyncio.sleep(delay)
        row_id = row.get("id", "?")
        history, error = parse_history(row.get("history", ""), row_id)
        if error:
            print(error)
            skipped += 1
            continue
        started = time.perf_counter()
        try:
            predicted, confidence, p_max, p_second, model = await classify(
                row["sentence"], history
            )
        except Exception as exc:
            latencies_ms.append((time.perf_counter() - started) * 1000)
            # Do not print the exception body: it must not leak a key.
            print(f"row {row_id}: classifier failed ({type(exc).__name__})")
            skipped += 1
            continue
        latencies_ms.append((time.perf_counter() - started) * 1000)
        scored.append(
            ScoredRow(
                id=str(row_id),
                sentence=row.get("sentence", ""),
                expected=row.get("intent", ""),
                predicted=str(predicted),
                confidence=confidence,
                p_max=p_max,
                p_second=p_second,
                model=model,
            )
        )
    return scored, skipped, latencies_ms


def load_rows(split: str) -> list[dict]:
    import csv

    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if split == "all":
        return rows
    return [row for row in rows if row.get("split") == split]


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Evaluate only the intent classifier (no extraction)."
    )
    parser.add_argument("--classifier", required=True, choices=["jev", "gemini"])
    parser.add_argument(
        "--delay",
        type=float,
        default=None,
        help="Seconds between rows. Default 0 for jev, 6 for gemini.",
    )
    parser.add_argument(
        "--split",
        default="all",
        help="CSV split to score, or all (default).",
    )
    return parser.parse_args(argv)


async def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.delay is not None and args.delay < 0:
        print("--delay must be 0 or more", file=sys.stderr)
        return 2
    delay = default_delay(args.classifier) if args.delay is None else args.delay
    rows = load_rows(args.split)
    if not rows:
        print(f"No rows for split {args.split!r}.")
        return 1
    classify = _classify_jev if args.classifier == "jev" else _classify_gemini
    scored, skipped, latencies_ms = await evaluate(rows, classify, delay)
    print(
        format_report(
            scored,
            classifier=args.classifier,
            skipped=skipped,
            latencies_ms=latencies_ms,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
