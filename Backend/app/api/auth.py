"""
Auth REST routes: register (dev-only), login, refresh, logout.
"""

from __future__ import annotations

import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel
from sqlalchemy.orm import joinedload

from app.auth.jwt_handler import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    decode_token,
)
from app.auth.password import hash_password, verify_password
from app.core.config import settings
from app.db.session import SessionLocal
from app.models.website_content import Role, RolePermission, User, UserRole

logger = logging.getLogger("caddystats.auth")

router = APIRouter(prefix="/auth", tags=["auth"])

_bearer = HTTPBearer(auto_error=False)


# ---------------------------------------------------------------------------
# Request / Response schemas
# ---------------------------------------------------------------------------


class RegisterRequest(BaseModel):
    email: str
    password: str
    username: str | None = None
    display_name: str | None = None


class LoginRequest(BaseModel):
    email: str
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _build_token_response(user: User) -> TokenResponse:
    """Issue access + refresh tokens for *user*."""
    roles: list[str] = [ur.role.key for ur in user.user_roles if ur.role]
    role = roles[0] if roles else "contributor"
    access = create_access_token(str(user.id), extra={"role": role, "email": user.email})
    refresh = create_refresh_token(str(user.id))
    return TokenResponse(
        access_token=access,
        refresh_token=refresh,
        expires_in=settings.access_token_expire_minutes * 60,
    )


def _load_user_with_roles(db, user_id: uuid.UUID) -> User | None:
    return (
        db.query(User)
        .options(
            joinedload(User.user_roles)
            .joinedload(UserRole.role)
            .joinedload(Role.role_permissions)
            .joinedload(RolePermission.permission)
        )
        .filter(User.id == user_id, User.is_active.is_(True), User.is_deleted.is_(False))
        .first()
    )


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user (development only)",
)
def register(body: RegisterRequest):
    """Create a new user account. Only available in development environment."""
    if settings.app_env != "development":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Registration disabled")

    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == body.email).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT, detail="Email already registered"
            )

        user = User(
            email=body.email,
            password_hash=hash_password(body.password),
            username=body.username,
            display_name=body.display_name,
            is_active=True,
            is_verified=False,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        user = _load_user_with_roles(db, user.id)
        logger.info("New user registered: %s", body.email)
        return _build_token_response(user)
    finally:
        db.close()


@router.post("/login", response_model=TokenResponse, summary="Authenticate and receive JWT tokens")
def login(body: LoginRequest):
    db = SessionLocal()
    try:
        user = (
            db.query(User)
            .options(joinedload(User.user_roles).joinedload(UserRole.role))
            .filter(User.email == body.email, User.is_deleted.is_(False))
            .first()
        )
        if not user or not verify_password(body.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials"
            )
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Account disabled"
            )
        logger.info("User logged in: %s", body.email)
        return _build_token_response(user)
    finally:
        db.close()


@router.post("/refresh", response_model=TokenResponse, summary="Exchange refresh token for new access token")
def refresh(body: RefreshRequest):
    try:
        payload = decode_refresh_token(body.refresh_token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired refresh token"
        )

    if payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Not a refresh token"
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    db = SessionLocal()
    try:
        user = _load_user_with_roles(db, uuid.UUID(user_id))
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or inactive"
            )
        return _build_token_response(user)
    finally:
        db.close()


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT, summary="Logout (client-side token invalidation)")
def logout(credentials: HTTPAuthorizationCredentials | None = Depends(_bearer)):
    """
    Signals logout. Token invalidation is client-side: the client discards the token.
    A server-side blacklist can be layered on here in a future iteration.
    """
    return None
