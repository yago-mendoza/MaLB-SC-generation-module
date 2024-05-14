import tempfile
from pathlib import Path

def load_if_exists(dspy_module, name):
    dir_tmp = Path(tempfile.gettempdir())
    if (dir_tmp / f"{dspy_module.__name__}_{name}.json").exists():
        dspy_module.load(name)

    return dspy_module

