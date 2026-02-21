# Backend/app/graphql/context.py
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional, Set, Tuple
import base64

from starlette.requests import Request


@dataclass(frozen=True)
class Viewer:
    user_id: str
    roles: Set[str]
    permissions: Set[str]


@dataclass
class GQLContext:
    request: Optional[Request] = None
    viewer: Optional[Viewer] = None


def require_auth(ctx: GQLContext) -> Viewer:
    if not ctx.viewer:
        raise Exception("UNAUTHORIZED")
    return ctx.viewer


def require_perm(ctx: GQLContext, perm: str) -> Viewer:
    viewer = require_auth(ctx)
    if perm not in viewer.permissions:
        raise Exception("FORBIDDEN")
    return viewer


# Cursor = base64("created_at_iso|uuid")
def encode_cursor(created_at_iso: str, row_id: str) -> str:
    raw = f"{created_at_iso}|{row_id}".encode("utf-8")
    return base64.b64encode(raw).decode("utf-8")


def decode_cursor(cursor: str) -> Tuple[str, str]:
    raw = base64.b64decode(cursor.encode("utf-8")).decode("utf-8")
    created_at_iso, row_id = raw.split("|", 1)
    return created_at_iso, row_id
