"""
SQLAlchemy ORM models for the website_content schema.

All tables live in the `website_content` Postgres schema.
"""

import uuid
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB, TSVECTOR, UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func


_SCHEMA = "website_content"


class Base(DeclarativeBase):
    pass


# ---------------------------------------------------------------------------
# Auth / RBAC
# ---------------------------------------------------------------------------

class User(Base):
    __tablename__ = "users"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    username: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True)
    password_hash: Mapped[str] = mapped_column(Text, nullable=False)
    display_name: Mapped[str | None] = mapped_column(Text, nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    user_roles: Mapped[list["UserRole"]] = relationship(back_populates="user")
    posts: Mapped[list["Post"]] = relationship(back_populates="author", foreign_keys="Post.author_id")
    pages: Mapped[list["Page"]] = relationship(back_populates="author", foreign_keys="Page.author_id")
    templates: Mapped[list["Template"]] = relationship(back_populates="author", foreign_keys="Template.author_id")


class Role(Base):
    __tablename__ = "roles"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    user_roles: Mapped[list["UserRole"]] = relationship(back_populates="role")
    role_permissions: Mapped[list["RolePermission"]] = relationship(back_populates="role")


class Permission(Base):
    __tablename__ = "permissions"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    role_permissions: Mapped[list["RolePermission"]] = relationship(back_populates="permission")


class UserRole(Base):
    __tablename__ = "user_roles"
    __table_args__ = (
        UniqueConstraint("user_id", "role_id", name="user_roles_unique"),
        {"schema": _SCHEMA},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="CASCADE"), nullable=False)
    role_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.roles.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    user: Mapped["User"] = relationship(back_populates="user_roles")
    role: Mapped["Role"] = relationship(back_populates="user_roles")


class RolePermission(Base):
    __tablename__ = "role_permissions"
    __table_args__ = (
        UniqueConstraint("role_id", "permission_id", name="role_permissions_unique"),
        {"schema": _SCHEMA},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    role_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.roles.id", ondelete="CASCADE"), nullable=False)
    permission_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.permissions.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    role: Mapped["Role"] = relationship(back_populates="role_permissions")
    permission: Mapped["Permission"] = relationship(back_populates="role_permissions")


# ---------------------------------------------------------------------------
# Taxonomy + SEO
# ---------------------------------------------------------------------------

class Tag(Base):
    __tablename__ = "tags"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    post_tags: Mapped[list["PostTag"]] = relationship(back_populates="tag")


class Category(Base):
    __tablename__ = "categories"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    parent_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.categories.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    children: Mapped[list["Category"]] = relationship(back_populates="parent")
    parent: Mapped["Category | None"] = relationship(back_populates="children", remote_side="Category.id")
    post_categories: Mapped[list["PostCategory"]] = relationship(back_populates="category")


class SEO(Base):
    __tablename__ = "seo"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title: Mapped[str | None] = mapped_column(Text, nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    canonical_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    og_title: Mapped[str | None] = mapped_column(Text, nullable=True)
    og_description: Mapped[str | None] = mapped_column(Text, nullable=True)
    og_image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    twitter_card: Mapped[str | None] = mapped_column(Text, nullable=True)
    noindex: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    nofollow: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())


# ---------------------------------------------------------------------------
# CMS content
# ---------------------------------------------------------------------------

class Post(Base):
    __tablename__ = "posts"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="RESTRICT"), nullable=False)
    seo_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.seo.id", ondelete="SET NULL"), nullable=True)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    excerpt: Mapped[str | None] = mapped_column(Text, nullable=True)
    featured_image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="draft")
    published_at: Mapped[datetime | None] = mapped_column(nullable=True)
    archived_at: Mapped[datetime | None] = mapped_column(nullable=True)
    content_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    search_vector: Mapped[str | None] = mapped_column(TSVECTOR, nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    author: Mapped["User"] = relationship(back_populates="posts", foreign_keys=[author_id])
    seo: Mapped["SEO | None"] = relationship()
    post_tags: Mapped[list["PostTag"]] = relationship(back_populates="post")
    post_categories: Mapped[list["PostCategory"]] = relationship(back_populates="post")
    comments: Mapped[list["Comment"]] = relationship(back_populates="post")
    revisions: Mapped[list["Revision"]] = relationship(
        primaryjoin="and_(Revision.entity_type=='post', foreign(Revision.entity_id)==Post.id)",
        viewonly=True,
    )


class Page(Base):
    __tablename__ = "pages"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="RESTRICT"), nullable=False)
    seo_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.seo.id", ondelete="SET NULL"), nullable=True)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    title: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="draft")
    published_at: Mapped[datetime | None] = mapped_column(nullable=True)
    archived_at: Mapped[datetime | None] = mapped_column(nullable=True)
    content_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    author: Mapped["User"] = relationship(back_populates="pages", foreign_keys=[author_id])
    seo: Mapped["SEO | None"] = relationship()


class Template(Base):
    __tablename__ = "templates"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    author_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="RESTRICT"), nullable=False)
    seo_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.seo.id", ondelete="SET NULL"), nullable=True)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="draft")
    content_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    author: Mapped["User"] = relationship(back_populates="templates", foreign_keys=[author_id])
    seo: Mapped["SEO | None"] = relationship()


class Block(Base):
    __tablename__ = "blocks"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_type: Mapped[str] = mapped_column(Text, nullable=False)
    owner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    block_type: Mapped[str] = mapped_column(Text, nullable=False)
    data_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())


class Revision(Base):
    __tablename__ = "revisions"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type: Mapped[str] = mapped_column(Text, nullable=False)
    entity_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    author_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="RESTRICT"), nullable=False)
    message: Mapped[str | None] = mapped_column(Text, nullable=True)
    snapshot_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())


class Comment(Base):
    __tablename__ = "comments"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.posts.id", ondelete="CASCADE"), nullable=False)
    author_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="SET NULL"), nullable=True)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="visible")
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    post: Mapped["Post"] = relationship(back_populates="comments")


class PostTag(Base):
    __tablename__ = "post_tags"
    __table_args__ = (
        UniqueConstraint("post_id", "tag_id", name="post_tags_unique"),
        {"schema": _SCHEMA},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.posts.id", ondelete="CASCADE"), nullable=False)
    tag_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.tags.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    post: Mapped["Post"] = relationship(back_populates="post_tags")
    tag: Mapped["Tag"] = relationship(back_populates="post_tags")


class PostCategory(Base):
    __tablename__ = "post_categories"
    __table_args__ = (
        UniqueConstraint("post_id", "category_id", name="post_categories_unique"),
        {"schema": _SCHEMA},
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    post_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.posts.id", ondelete="CASCADE"), nullable=False)
    category_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.categories.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    post: Mapped["Post"] = relationship(back_populates="post_categories")
    category: Mapped["Category"] = relationship(back_populates="post_categories")


# ---------------------------------------------------------------------------
# Media / Uploads
# ---------------------------------------------------------------------------

class MediaAsset(Base):
    __tablename__ = "media_assets"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    uploader_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="SET NULL"), nullable=True)
    file_name: Mapped[str] = mapped_column(Text, nullable=False)
    content_type: Mapped[str] = mapped_column(Text, nullable=False)
    byte_size: Mapped[int] = mapped_column(BigInteger, nullable=False)
    storage_provider: Mapped[str] = mapped_column(Text, nullable=False, default="s3")
    storage_bucket: Mapped[str | None] = mapped_column(Text, nullable=True)
    storage_key: Mapped[str] = mapped_column(Text, nullable=False)
    public_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    checksum_sha256: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    asset_links: Mapped[list["AssetLink"]] = relationship(back_populates="asset")


class AssetLink(Base):
    __tablename__ = "asset_links"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    asset_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.media_assets.id", ondelete="CASCADE"), nullable=False)
    owner_type: Mapped[str] = mapped_column(Text, nullable=False)
    owner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    asset: Mapped["MediaAsset"] = relationship(back_populates="asset_links")


# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------

class NavMenu(Base):
    __tablename__ = "nav_menus"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    items: Mapped[list["NavItem"]] = relationship(back_populates="menu", foreign_keys="NavItem.menu_id")


class NavItem(Base):
    __tablename__ = "nav_items"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    menu_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.nav_menus.id", ondelete="CASCADE"), nullable=False)
    parent_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.nav_items.id", ondelete="CASCADE"), nullable=True)
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    label: Mapped[str] = mapped_column(Text, nullable=False)
    href: Mapped[str | None] = mapped_column(Text, nullable=True)
    page_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.pages.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    menu: Mapped["NavMenu"] = relationship(back_populates="items", foreign_keys=[menu_id])
    children: Mapped[list["NavItem"]] = relationship(back_populates="parent_item", foreign_keys=[parent_id])
    parent_item: Mapped["NavItem | None"] = relationship(back_populates="children", remote_side="NavItem.id", foreign_keys=[parent_id])


# ---------------------------------------------------------------------------
# Marketplace
# ---------------------------------------------------------------------------

class Product(Base):
    __tablename__ = "products"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    product_type: Mapped[str] = mapped_column(Text, nullable=False, default="template")
    price_cents: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    currency: Mapped[str] = mapped_column(String(10), nullable=False, default="USD")
    status: Mapped[str] = mapped_column(Text, nullable=False, default="draft")
    published_at: Mapped[datetime | None] = mapped_column(nullable=True)
    seo_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.seo.id", ondelete="SET NULL"), nullable=True)
    search_vector: Mapped[str | None] = mapped_column(TSVECTOR, nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    seo: Mapped["SEO | None"] = relationship()
    licenses: Mapped[list["License"]] = relationship(back_populates="product")
    purchases: Mapped[list["Purchase"]] = relationship(back_populates="product")


class License(Base):
    __tablename__ = "licenses"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    product_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.products.id", ondelete="RESTRICT"), nullable=False)
    user_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="SET NULL"), nullable=True)
    license_key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="active")
    expires_at: Mapped[datetime | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    product: Mapped["Product"] = relationship(back_populates="licenses")


class Purchase(Base):
    __tablename__ = "purchases"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="SET NULL"), nullable=True)
    product_id: Mapped[uuid.UUID] = mapped_column(ForeignKey(f"{_SCHEMA}.products.id", ondelete="RESTRICT"), nullable=False)
    license_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.licenses.id", ondelete="SET NULL"), nullable=True)
    amount_cents: Mapped[int] = mapped_column(Integer, nullable=False)
    currency: Mapped[str] = mapped_column(String(10), nullable=False, default="USD")
    provider: Mapped[str] = mapped_column(Text, nullable=False, default="manual")
    provider_txn_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(Text, nullable=False, default="completed")
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    product: Mapped["Product"] = relationship(back_populates="purchases")


# ---------------------------------------------------------------------------
# Analytics Events
# ---------------------------------------------------------------------------

class Event(Base):
    __tablename__ = "events"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_type: Mapped[str] = mapped_column(Text, nullable=False)
    user_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey(f"{_SCHEMA}.users.id", ondelete="SET NULL"), nullable=True)
    session_id: Mapped[str | None] = mapped_column(Text, nullable=True)
    path: Mapped[str | None] = mapped_column(Text, nullable=True)
    referrer: Mapped[str | None] = mapped_column(Text, nullable=True)
    properties: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
