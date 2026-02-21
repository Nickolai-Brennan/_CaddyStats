# Backend/app/db/repos/posts_repo.py
from __future__ import annotations

from typing import Optional, List, Tuple
from sqlalchemy import text
from sqlalchemy.orm import Session

def list_posts(
    db: Session,
    first: int,
    after_created_at: Optional[str],
    after_id: Optional[str],
    status: Optional[str],
) -> List[Tuple[str, str, str, str, str]]:
    # returns rows: (id, title, slug, status, created_at_iso)
    where = ["p.is_deleted = false"]
    params = {"limit": first + 1}

    if status:
        where.append("p.status = :status")
        params["status"] = status

    # cursor gate (created_at DESC, id DESC)
    if after_created_at and after_id:
        where.append("(p.created_at, p.id) < (:after_created_at::timestamptz, :after_id::uuid)")
        params["after_created_at"] = after_created_at
        params["after_id"] = after_id

    sql = f"""
      SELECT p.id::text, p.title, p.slug, p.status, to_char(p.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as created_at_iso
      FROM website_content.posts p
      WHERE {' AND '.join(where)}
      ORDER BY p.created_at DESC, p.id DESC
      LIMIT :limit
    """

    return list(db.execute(text(sql), params).fetchall())
