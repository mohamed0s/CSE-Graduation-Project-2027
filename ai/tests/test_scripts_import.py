"""Scripts must import `app` even when only scripts/ is on sys.path."""

import importlib.util
import subprocess
import sys
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent
_SCRIPTS = _ROOT / "scripts"
_NAMES = ("manual_test.py", "run_eval.py", "run_classifier_eval.py")


def test_scripts_import_as_modules_without_repo_root_on_path():
    code = r"""
import importlib.util
import sys
from pathlib import Path

script = Path(sys.argv[1]).resolve()
root = script.parent.parent

def is_root(entry):
    if not entry:
        return Path.cwd().resolve() == root
    try:
        return Path(entry).resolve() == root
    except OSError:
        return False

sys.path = [str(script.parent)] + [entry for entry in sys.path if not is_root(entry)]
name = script.stem + "_imported"
spec = importlib.util.spec_from_file_location(name, script)
module = importlib.util.module_from_spec(spec)
sys.modules[name] = module
spec.loader.exec_module(module)
import app
assert str(root) in sys.path
"""
    for name in _NAMES:
        completed = subprocess.run(
            [sys.executable, "-c", code, str(_SCRIPTS / name)],
            cwd=str(_SCRIPTS),
            capture_output=True,
            text=True,
        )
        assert completed.returncode == 0, completed.stderr


def test_scripts_import_from_repo_root_path():
    for name in _NAMES:
        path = _SCRIPTS / name
        spec = importlib.util.spec_from_file_location(f"scripts_{path.stem}", path)
        module = importlib.util.module_from_spec(spec)
        sys.modules[spec.name] = module
        spec.loader.exec_module(module)
        assert module.__file__
