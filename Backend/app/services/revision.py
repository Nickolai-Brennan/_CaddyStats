"""
Revision tracking service.
Creates snapshot records in the website_content.revisions table.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional

from app.models.website_content import Revision


def create_revision(
    session,
    *,
    entity_type: str,
    entity_id: uuid.UUID,
    author_id: uuid.UUID,
    message: Optional[str] = None,
    snapshot_data: dict,
) -> Revision:
    """
    Create a revision snapshot for the given entity.

    The version counter is derived from the number of existing revisions for
    this entity, so it increments automatically without a dedicated column.
    """
    revision = Revision(
        entity_type=entity_type,
        entity_id=entity_id,
        author_id=author_id,
        message=message,
        snapshot_jsonb=snapshot_data,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )
    session.add(revision)
    return revision
