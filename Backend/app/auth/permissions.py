"""
Permissions – role-based access control helpers.
Populated in Phase 2+ (auth integration).
"""

from typing import Callable

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
