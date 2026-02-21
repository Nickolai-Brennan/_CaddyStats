"""
Permissions – role-based access control helpers.
"""

from typing import Callable, Set

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.auth.jwt_handler import decode_access_token

ROLE_HIERARCHY = {"contributor": 1, "editor": 2, "admin": 3}

_bearer = HTTPBearer(auto_error=False)


def _get_role(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)) -> str:
    """Extract the caller's role from the Bearer JWT, defaulting to 'contributor'."""
    if credentials is None:
        return "contributor"
    try:
        payload = decode_access_token(credentials.credentials)
        return payload.get("role", "contributor")
    except Exception:
        return "contributor"


def require_role(minimum_role: str) -> Callable:
    """FastAPI dependency factory: enforce a minimum role level."""

    def _check(role: str = Depends(_get_role)) -> None:
        if ROLE_HIERARCHY.get(role, 0) < ROLE_HIERARCHY.get(minimum_role, 0):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )

    return Depends(_check)


def has_permission(user_permissions: Set[str], permission_key: str) -> bool:
    """Check if the given set of permissions contains the requested key."""
    return permission_key in user_permissions


def get_user_permissions_from_viewer(viewer) -> Set[str]:
    """Return all permission keys from a Viewer context object."""
    if viewer is None:
        return set()
    return set(viewer.permissions)
