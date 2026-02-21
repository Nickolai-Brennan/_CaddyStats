"""
Media upload REST endpoints.
POST /api/media/upload  – upload a file
GET  /api/media/list    – list uploaded media (paginated)
DELETE /api/media/{id}  – soft-delete a media record
"""

from __future__ import annotations

import logging
import os
import uuid
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.auth.jwt_handler import decode_token
from app.core.config import settings
from app.db.session import SessionLocal
from app.models.website_content import MediaAsset

logger = logging.getLogger("caddystats.media")

router = APIRouter(prefix="/media", tags=["media"])

_bearer = HTTPBearer(auto_error=False)

_MAX_BYTES = settings.upload_max_size_mb * 1024 * 1024


# ---------------------------------------------------------------------------
# Auth dependency
# ---------------------------------------------------------------------------


def _get_current_user_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> uuid.UUID:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Not authenticated")
    payload = decode_token(credentials.credentials)
    if not payload or payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return uuid.UUID(payload["sub"])


# ---------------------------------------------------------------------------
# Response models
# ---------------------------------------------------------------------------


class MediaResponse(BaseModel):
    id: uuid.UUID
    url: Optional[str]
    filename: str
    content_type: str
    byte_size: int
    storage_provider: str
    storage_key: str
    created_at: datetime

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _ensure_storage_dir() -> str:
    path = settings.upload_storage_path
    os.makedirs(path, exist_ok=True)
    return path


def _orm_to_response(asset: MediaAsset) -> MediaResponse:
    return MediaResponse(
        id=asset.id,
        url=asset.public_url,
        filename=asset.file_name,
        content_type=asset.content_type,
        byte_size=asset.byte_size,
        storage_provider=asset.storage_provider,
        storage_key=asset.storage_key,
        created_at=asset.created_at,
    )


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------


@router.post(
    "/upload",
    response_model=MediaResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload a media file",
)
async def upload_media(
    file: UploadFile,
    current_user_id: uuid.UUID = Depends(_get_current_user_id),
):
    # Validate MIME type
    if file.content_type not in settings.upload_allowed_mimes:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Unsupported media type: {file.content_type}",
        )

    content = await file.read()

    # Validate file size
    if len(content) > _MAX_BYTES:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"File exceeds the {settings.upload_max_size_mb} MB limit",
        )

    # Persist to local storage
    storage_dir = _ensure_storage_dir()
    file_id = uuid.uuid4()
    ext = os.path.splitext(file.filename or "upload")[1]
    storage_key = f"{file_id}{ext}"
    dest = os.path.join(storage_dir, storage_key)
    with open(dest, "wb") as fh:
        fh.write(content)

    public_url = f"/media/files/{storage_key}"

    db: Session = SessionLocal()
    try:
        asset = MediaAsset(
            uploader_id=current_user_id,
            file_name=file.filename or storage_key,
            content_type=file.content_type,
            byte_size=len(content),
            storage_provider="local",
            storage_key=storage_key,
            public_url=public_url,
        )
        db.add(asset)
        db.commit()
        db.refresh(asset)
        logger.info("Media uploaded: %s by user %s", storage_key, current_user_id)
        return _orm_to_response(asset)
    finally:
        db.close()


@router.get("/list", response_model=list[MediaResponse], summary="List uploaded media")
def list_media(
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
    current_user_id: uuid.UUID = Depends(_get_current_user_id),
):
    offset = (page - 1) * per_page
    db: Session = SessionLocal()
    try:
        rows = (
            db.query(MediaAsset)
            .order_by(MediaAsset.created_at.desc())
            .offset(offset)
            .limit(per_page)
            .all()
        )
        return [_orm_to_response(a) for a in rows]
    finally:
        db.close()


@router.delete("/{media_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete a media record")
def delete_media(
    media_id: uuid.UUID,
    current_user_id: uuid.UUID = Depends(_get_current_user_id),
):
    db: Session = SessionLocal()
    try:
        asset = db.query(MediaAsset).filter(MediaAsset.id == media_id).first()
        if not asset:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Media not found")

        # Attempt to remove local file
        storage_dir = settings.upload_storage_path
        local_path = os.path.join(storage_dir, asset.storage_key)
        if os.path.exists(local_path):
            try:
                os.remove(local_path)
            except OSError as exc:
                logger.warning("Could not remove file %s: %s", local_path, exc)

        db.delete(asset)
        db.commit()
        return None
    finally:
        db.close()
