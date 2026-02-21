# Backend/app/api/graphql_router.py
from __future__ import annotations

import logging

from fastapi import APIRouter
from sqlalchemy.orm import Session, joinedload
from starlette.requests import Request

from app.auth.jwt_handler import decode_token
from app.db.session import SessionLocal
from app.graphql.context import GQLContext, Viewer
from app.models.website_content import User, UserRole, Role, RolePermission, Permission

logger = logging.getLogger("caddystats.auth")

router = APIRouter()


def _load_viewer(db: Session, user_id: str) -> Viewer | None:
    """Load a user with all roles/permissions and build a Viewer context."""
    try:
        user = (
            db.query(User)
            .options(
                joinedload(User.user_roles)
                .joinedload(UserRole.role)
                .joinedload(Role.role_permissions)
                .joinedload(RolePermission.permission)
            )
            .filter(User.id == user_id, User.is_active == True, User.is_deleted == False)
            .first()
        )
        if not user:
            return None
        roles: set[str] = set()
        permissions: set[str] = set()
        for ur in user.user_roles:
            if ur.role:
                roles.add(ur.role.key)
                for rp in ur.role.role_permissions:
                    if rp.permission:
                        permissions.add(rp.permission.key)
        return Viewer(user_id=str(user.id), roles=roles, permissions=permissions)
    except Exception:
        logger.exception("Failed to load viewer for user_id=%s", user_id)
        return None


async def get_context(request: Request) -> GQLContext:
    """Build GQLContext from the incoming request's Authorization header."""
    auth = request.headers.get("authorization", "")
    viewer: Viewer | None = None

    if auth.startswith("Bearer "):
        token = auth[len("Bearer "):]
        payload = decode_token(token)
        if payload and payload.get("type") == "access":
            user_id = payload.get("sub")
            if user_id:
                db = SessionLocal()
                try:
                    viewer = _load_viewer(db, user_id)
                finally:
                    db.close()

    return GQLContext(request=request, viewer=viewer)
