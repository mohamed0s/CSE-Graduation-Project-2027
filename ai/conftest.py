# Makes pytest import `app` from the repo root (tests/ has no __init__.py).

import pytest


@pytest.fixture(autouse=True)
def _reset_reliability_state():
    """Breaker and rate-limit state must not leak between tests."""
    from app.ai.reliability import reset_state

    reset_state()
    yield
    reset_state()


@pytest.fixture(autouse=True)
def _classifier_provider_for_existing_tests(monkeypatch):
    """Existing parse_request tests expect the LLM classifier.

    The app has no silent default. This fixture only keeps those tests on
    the gemini path unless a test sets CLASSIFIER_PROVIDER itself.
    """
    monkeypatch.setenv("CLASSIFIER_PROVIDER", "gemini")
