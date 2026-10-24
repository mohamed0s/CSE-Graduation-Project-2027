"""Fail if an eval sentence also appears as a prompt or Jev example.

Offline. No network. The check lives in scripts/check_leakage.py.
"""

import importlib.util
import sys
from pathlib import Path


def _load():
    path = Path(__file__).resolve().parent.parent / "scripts" / "check_leakage.py"
    spec = importlib.util.spec_from_file_location("check_leakage", path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_eval_sentences_are_not_prompt_examples(capsys):
    module = _load()
    code = module.main()
    out = capsys.readouterr().out
    assert code == 0, out
