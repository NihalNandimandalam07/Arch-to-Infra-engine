"""Architecture IR: schema access and validation helpers."""

import json
from functools import cache
from pathlib import Path
from typing import Any

SCHEMA_PATH = Path(__file__).with_name("schema.json")
EXAMPLES_DIR = Path(__file__).with_name("examples")


@cache
def load_schema() -> dict[str, Any]:
    """Return the Architecture IR JSON Schema (cached)."""
    return json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
