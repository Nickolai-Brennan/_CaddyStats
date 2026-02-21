"""
Post draft/publish workflow service.
Handles status transitions: draft → review → published → archived.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional

from app.models.website_content import Post

# Allowed status transitions
_TRANSITIONS: dict[str, set[str]] = {
    "draft": {"review", "published"},
    "review": {"draft", "published"},
    "published": {"draft", "archived"},
    "archived": {"draft"},
}


def can_transition(current_status: str, target_status: str) -> bool:
    """Return True if the transition from *current_status* to *target_status* is valid."""
    return target_status in _TRANSITIONS.get(current_status, set())


def can_publish(viewer, post: Post) -> bool:
    """Return True if *viewer* has the post:publish permission."""
    if viewer is None:
        return False
    return "post:publish" in viewer.permissions


def publish_post(session, post_id: uuid.UUID, author_id: uuid.UUID) -> Post:
    """
    Transition a post to 'published' status, setting published_at to now.
    Raises ValueError if the post is not found or the transition is invalid.
    """
    post = session.query(Post).filter(Post.id == post_id, Post.is_deleted.is_(False)).first()
    if not post:
        raise ValueError(f"Post {post_id} not found")

    if not can_transition(post.status, "published"):
        raise ValueError(f"Cannot publish a post with status '{post.status}'")

    now = datetime.now(timezone.utc)
    post.status = "published"
    post.published_at = now
    post.updated_at = now
    return post


def unpublish_post(session, post_id: uuid.UUID, author_id: uuid.UUID) -> Post:
    """Transition a post back to 'draft' status."""
    post = session.query(Post).filter(Post.id == post_id, Post.is_deleted.is_(False)).first()
    if not post:
        raise ValueError(f"Post {post_id} not found")

    if not can_transition(post.status, "draft"):
        raise ValueError(f"Cannot unpublish a post with status '{post.status}'")

    post.status = "draft"
    post.published_at = None
    post.updated_at = datetime.now(timezone.utc)
    return post


def archive_post(session, post_id: uuid.UUID) -> Post:
    """Transition a post to 'archived' status."""
    post = session.query(Post).filter(Post.id == post_id, Post.is_deleted.is_(False)).first()
    if not post:
        raise ValueError(f"Post {post_id} not found")

    if not can_transition(post.status, "archived"):
        raise ValueError(f"Cannot archive a post with status '{post.status}'")

    now = datetime.now(timezone.utc)
    post.status = "archived"
    post.archived_at = now
    post.updated_at = now
    return post
