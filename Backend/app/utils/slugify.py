"""
Slugify utility – convert strings to URL-safe slugs.
"""

import re
import unicodedata


def slugify(text: str) -> str:
    """Return a lowercase, hyphen-separated URL slug for *text*."""
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-{2,}", "-", text)
    return text.strip("-")
