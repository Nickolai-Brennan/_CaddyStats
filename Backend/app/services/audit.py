"""
Audit logging service.
Writes audit events to the website_content.audit_logs table when available,
with a fallback to structured Python logging.
"""

from __future__ import annotations

import json
import logging
import uuid
from datetime import datetime, timezone
from typing import Any, Optional

logger = logging.getLogger("caddystats.audit")


def log_audit(
    session,
    *,
    user_id: Optional[uuid.UUID],
    action: str,
    entity_type: str,
    entity_id: Optional[uuid.UUID] = None,
    metadata: Optional[dict[str, Any]] = None,
) -> None:
    """
    Record an audit event.

    Attempts to write to the audit_logs table; falls back to structured
    Python logging if the table does not yet exist (graceful degradation).
    """
    from sqlalchemy import text

    record = {
        "user_id": str(user_id) if user_id else None,
        "action": action,
        "entity_type": entity_type,
        "entity_id": str(entity_id) if entity_id else None,
        "metadata": metadata or {},
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    try:
        session.execute(
            text(
                """
                INSERT INTO website_content.audit_logs
                    (id, user_id, action, entity_type, entity_id, metadata_jsonb, created_at)
                VALUES
                    (:id, :user_id::uuid, :action, :entity_type, :entity_id::uuid, :metadata::jsonb, NOW())
                """
            ),
            {
                "id": str(uuid.uuid4()),
                "user_id": record["user_id"],
                "action": action,
                "entity_type": entity_type,
                "entity_id": record["entity_id"],
                "metadata": json.dumps(record["metadata"]),
            },
        )
    except Exception:
        # Table may not exist yet – degrade gracefully
        logger.info(
            "AUDIT | user=%s action=%s entity_type=%s entity_id=%s metadata=%s",
            record["user_id"],
            action,
            entity_type,
            record["entity_id"],
            record["metadata"],
        )
