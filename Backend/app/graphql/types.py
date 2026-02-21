"""
GraphQL type definitions for the website_content schema.
Includes all domain types plus Relay-style pagination helpers.
"""

from __future__ import annotations

import uuid
from datetime import datetime
from typing import Generic, List, Optional, TypeVar

import strawberry


# ---------------------------------------------------------------------------
# Relay pagination helpers
# ---------------------------------------------------------------------------

@strawberry.type
class PageInfo:
    has_next_page: bool
    has_previous_page: bool
    start_cursor: Optional[str]
    end_cursor: Optional[str]


NodeType = TypeVar("NodeType")


@strawberry.type
class Edge(Generic[NodeType]):
    cursor: str
    node: NodeType


@strawberry.type
class Connection(Generic[NodeType]):
    edges: List[Edge[NodeType]]
    page_info: PageInfo
    total_count: int


# ---------------------------------------------------------------------------
# Auth / RBAC types
# ---------------------------------------------------------------------------

@strawberry.type
class Permission:
    id: uuid.UUID
    key: str
    name: str
    description: Optional[str]
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Role:
    id: uuid.UUID
    key: str
    name: str
    description: Optional[str]
    permissions: List[Permission]
    created_at: datetime
    updated_at: datetime


@strawberry.type
class User:
    id: uuid.UUID
    email: str
    username: Optional[str]
    display_name: Optional[str]
    avatar_url: Optional[str]
    is_active: bool
    is_verified: bool
    roles: List[Role]
    created_at: datetime
    updated_at: datetime


@strawberry.type
class AuthPayload:
    access_token: str
    token_type: str
    expires_in: int
    viewer: User


# ---------------------------------------------------------------------------
# SEO type
# ---------------------------------------------------------------------------

@strawberry.type
class SEO:
    id: uuid.UUID
    title: Optional[str]
    description: Optional[str]
    canonical_url: Optional[str]
    og_title: Optional[str]
    og_description: Optional[str]
    og_image_url: Optional[str]
    twitter_card: Optional[str]
    noindex: bool
    nofollow: bool
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Taxonomy types
# ---------------------------------------------------------------------------

@strawberry.type
class Tag:
    id: uuid.UUID
    slug: str
    name: str
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Category:
    id: uuid.UUID
    slug: str
    name: str
    parent_id: Optional[uuid.UUID]
    children: List["Category"]
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# CMS content types
# ---------------------------------------------------------------------------

@strawberry.type
class Block:
    id: uuid.UUID
    owner_type: str
    owner_id: uuid.UUID
    sort_order: int
    block_type: str
    data_jsonb: strawberry.scalars.JSON
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Revision:
    id: uuid.UUID
    entity_type: str
    entity_id: uuid.UUID
    author: User
    message: Optional[str]
    snapshot_jsonb: strawberry.scalars.JSON
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Comment:
    id: uuid.UUID
    post_id: uuid.UUID
    author: Optional[User]
    body: str
    status: str
    is_deleted: bool
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Post:
    id: uuid.UUID
    author: User
    seo: Optional[SEO]
    slug: str
    title: str
    excerpt: Optional[str]
    featured_image_url: Optional[str]
    status: str
    published_at: Optional[datetime]
    archived_at: Optional[datetime]
    content_jsonb: strawberry.scalars.JSON
    tags: List[Tag]
    categories: List[Category]
    comments: List[Comment]
    is_deleted: bool
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Page:
    id: uuid.UUID
    author: User
    seo: Optional[SEO]
    slug: str
    title: str
    status: str
    published_at: Optional[datetime]
    archived_at: Optional[datetime]
    content_jsonb: strawberry.scalars.JSON
    is_deleted: bool
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Template:
    id: uuid.UUID
    author: User
    seo: Optional[SEO]
    slug: str
    name: str
    description: Optional[str]
    status: str
    content_jsonb: strawberry.scalars.JSON
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Media type
# ---------------------------------------------------------------------------

@strawberry.type
class MediaAsset:
    id: uuid.UUID
    uploader: Optional[User]
    file_name: str
    content_type: str
    byte_size: int
    storage_provider: str
    storage_bucket: Optional[str]
    storage_key: str
    public_url: Optional[str]
    checksum_sha256: Optional[str]
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Navigation types
# ---------------------------------------------------------------------------

@strawberry.type
class NavItem:
    id: uuid.UUID
    menu_id: uuid.UUID
    parent_id: Optional[uuid.UUID]
    sort_order: int
    label: str
    href: Optional[str]
    page_id: Optional[uuid.UUID]
    children: List["NavItem"]
    created_at: datetime
    updated_at: datetime


@strawberry.type
class NavMenu:
    id: uuid.UUID
    slug: str
    name: str
    items: List[NavItem]
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Marketplace types
# ---------------------------------------------------------------------------

@strawberry.type
class License:
    id: uuid.UUID
    product_id: uuid.UUID
    user: Optional[User]
    license_key: str
    status: str
    expires_at: Optional[datetime]
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Purchase:
    id: uuid.UUID
    user: Optional[User]
    product_id: uuid.UUID
    license: Optional[License]
    amount_cents: int
    currency: str
    provider: str
    provider_txn_id: Optional[str]
    status: str
    created_at: datetime
    updated_at: datetime


@strawberry.type
class Product:
    id: uuid.UUID
    slug: str
    name: str
    description: Optional[str]
    product_type: str
    price_cents: int
    currency: str
    status: str
    published_at: Optional[datetime]
    seo: Optional[SEO]
    is_deleted: bool
    created_at: datetime
    updated_at: datetime


# ---------------------------------------------------------------------------
# Analytics Event type
# ---------------------------------------------------------------------------

@strawberry.type
class Event:
    id: uuid.UUID
    event_type: str
    user: Optional[User]
    session_id: Optional[str]
    path: Optional[str]
    referrer: Optional[str]
    properties: Optional[strawberry.scalars.JSON]
    created_at: datetime


# ---------------------------------------------------------------------------
# External Stats API gateway types (thin – no local DB)
# ---------------------------------------------------------------------------

@strawberry.type
class TournamentCard:
    tournament_id: str
    name: Optional[str]
    raw: strawberry.scalars.JSON


@strawberry.type
class LeaderboardEntry:
    position: int
    player_name: str
    score: Optional[str]
    raw: strawberry.scalars.JSON


@strawberry.type
class FeaturedEdge:
    player_name: str
    raw: strawberry.scalars.JSON


# ---------------------------------------------------------------------------
# Filter / sort inputs
# ---------------------------------------------------------------------------

@strawberry.input
class PostFilterInput:
    status: Optional[str] = None
    author_id: Optional[uuid.UUID] = None
    tag_ids: Optional[List[uuid.UUID]] = None
    category_ids: Optional[List[uuid.UUID]] = None


@strawberry.input
class ProductFilterInput:
    status: Optional[str] = None
    product_type: Optional[str] = None


@strawberry.input
class SortInput:
    field: str = "created_at"
    direction: str = "DESC"


# ---------------------------------------------------------------------------
# Mutation input types
# ---------------------------------------------------------------------------

@strawberry.input
class SEOInput:
    title: Optional[str] = None
    description: Optional[str] = None
    canonical_url: Optional[str] = None
    og_title: Optional[str] = None
    og_description: Optional[str] = None
    og_image_url: Optional[str] = None
    twitter_card: Optional[str] = None
    noindex: bool = False
    nofollow: bool = False


@strawberry.input
class CreatePostInput:
    title: str
    slug: str
    excerpt: Optional[str] = None
    featured_image_url: Optional[str] = None
    content_jsonb: Optional[strawberry.scalars.JSON] = None
    tag_ids: Optional[List[uuid.UUID]] = None
    category_ids: Optional[List[uuid.UUID]] = None
    seo: Optional[SEOInput] = None


@strawberry.input
class UpdatePostInput:
    title: Optional[str] = None
    slug: Optional[str] = None
    excerpt: Optional[str] = None
    featured_image_url: Optional[str] = None
    content_jsonb: Optional[strawberry.scalars.JSON] = None
    tag_ids: Optional[List[uuid.UUID]] = None
    category_ids: Optional[List[uuid.UUID]] = None
    seo: Optional[SEOInput] = None


@strawberry.input
class CreateTemplateInput:
    slug: str
    name: str
    description: Optional[str] = None
    content_jsonb: Optional[strawberry.scalars.JSON] = None
    seo: Optional[SEOInput] = None


@strawberry.input
class UpdateTemplateInput:
    slug: Optional[str] = None
    name: Optional[str] = None
    description: Optional[str] = None
    content_jsonb: Optional[strawberry.scalars.JSON] = None
    seo: Optional[SEOInput] = None


@strawberry.input
class AddBlockInput:
    owner_type: str
    owner_id: uuid.UUID
    block_type: str
    data_jsonb: strawberry.scalars.JSON
    sort_order: int = 0


@strawberry.input
class UploadAssetReferenceInput:
    file_name: str
    content_type: str
    byte_size: int
    storage_provider: str
    storage_key: str
    storage_bucket: Optional[str] = None
    public_url: Optional[str] = None
    checksum_sha256: Optional[str] = None


@strawberry.input
class CreatePurchaseInput:
    product_id: uuid.UUID
    amount_cents: int
    currency: str = "USD"
    provider: str = "manual"
    provider_txn_id: Optional[str] = None


@strawberry.input
class VerifyLicenseInput:
    license_key: str
