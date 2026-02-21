"""
Slugify utility – convert strings to URL-safe slugs.
"""

import re
import unicodedata
from typing import Optional


def slugify(text: str) -> str:
    """Return a lowercase, hyphen-separated URL slug for *text*."""
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    text = text.lower()
    text = re.sub(r"[^\w\s-]", "", text)
    text = re.sub(r"[\s_]+", "-", text)
    text = re.sub(r"-{2,}", "-", text)
    return text.strip("-")


def generate_unique_slug(session, model, title: str, base_slug: Optional[str] = None) -> str:
    """
    Generate a unique slug for *model* derived from *title*.

    If *base_slug* is provided it is used as the starting point; otherwise
    :func:`slugify` is applied to *title*.  On collision the suffix ``-2``,
    ``-3``, … is appended until a free slot is found.
    """
    candidate = base_slug if base_slug else slugify(title)
    if not candidate:
        candidate = "untitled"

    slug = candidate
    counter = 2
    while True:
        exists = session.query(model).filter(model.slug == slug).first()
        if not exists:
            return slug
        slug = f"{candidate}-{counter}"
        counter += 1

