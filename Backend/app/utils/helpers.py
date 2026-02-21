"""
General-purpose helper utilities.
"""

from typing import Any


def strip_none(data: dict[str, Any]) -> dict[str, Any]:
    """Return a shallow copy of *data* with all None values removed."""
    return {k: v for k, v in data.items() if v is not None}


def chunk(lst: list, size: int) -> list[list]:
    """Split *lst* into sub-lists of at most *size* elements."""
    return [lst[i : i + size] for i in range(0, len(lst), size)]
