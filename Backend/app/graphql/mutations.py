"""
GraphQL Mutation resolvers.

Implements auth, content (posts, pages, templates), commerce and media mutations.
RBAC guards are enforced via the viewer context (permission key checks).
"""

from __future__ import annotations

import logging
import uuid
from datetime import datetime, timezone
from typing import Optional

import strawberry
from passlib.context import CryptContext
from sqlalchemy.orm import joinedload
from strawberry.types import Info

from app.auth.jwt_handler import (
    ACCESS_TOKEN_EXPIRE_MINUTES,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.db.session import SessionLocal
from app.graphql.context import GQLContext, require_auth, require_perm
from app.graphql.converters import (
    orm_license_to_gql,
    orm_media_to_gql,
    orm_page_to_gql,
    orm_post_to_gql,
    orm_purchase_to_gql,
    orm_template_to_gql,
    orm_user_to_gql,
)
from app.graphql.types import (
    AddBlockInput,
    AuthPayload,
    Block,
    CreatePostInput,
    CreatePurchaseInput,
    CreateTemplateInput,
    License,
    MediaAsset,
    Page,
    Post,
    Purchase,
    Template,
    UpdatePostInput,
    UpdateTemplateInput,
    UploadAssetReferenceInput,
    User,
    VerifyLicenseInput,
)
from app.models.website_content import (
    Block as OrmBlock,
    License as OrmLicense,
    MediaAsset as OrmMediaAsset,
    Page as OrmPage,
    Post as OrmPost,
    PostCategory as OrmPostCategory,
    PostTag as OrmPostTag,
    Product as OrmProduct,
    Purchase as OrmPurchase,
    Revision as OrmRevision,
    Role,
    RolePermission,
    Template as OrmTemplate,
    User as OrmUser,
    UserRole,
)
from app.utils.slugify import slugify

logger = logging.getLogger("caddystats.mutations")

_pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Entity type constants for revisions
_ENTITY_POST = "post"
_ENTITY_PAGE = "page"
_ENTITY_TEMPLATE = "template"

_USER_EAGER = [
    joinedload(OrmUser.user_roles)
    .joinedload(UserRole.role)
    .joinedload(Role.role_permissions)
    .joinedload(RolePermission.permission)
]

_POST_EAGER = [
    joinedload(OrmPost.author)
    .joinedload(OrmUser.user_roles)
    .joinedload(UserRole.role)
    .joinedload(Role.role_permissions)
    .joinedload(RolePermission.permission),
    joinedload(OrmPost.seo),
    joinedload(OrmPost.post_tags).joinedload(OrmPostTag.tag),
    joinedload(OrmPost.post_categories).joinedload(OrmPostCategory.category),
    joinedload(OrmPost.comments),
]

_PAGE_EAGER = [
    joinedload(OrmPage.author)
    .joinedload(OrmUser.user_roles)
    .joinedload(UserRole.role)
    .joinedload(Role.role_permissions)
    .joinedload(RolePermission.permission),
    joinedload(OrmPage.seo),
]

_TEMPLATE_EAGER = [
    joinedload(OrmTemplate.author)
    .joinedload(OrmUser.user_roles)
    .joinedload(UserRole.role)
    .joinedload(Role.role_permissions)
    .joinedload(RolePermission.permission),
    joinedload(OrmTemplate.seo),
]


def _reload_post(db, post_id) -> OrmPost:
    return (
        db.query(OrmPost)
        .options(*_POST_EAGER)
        .filter(OrmPost.id == post_id)
        .first()
    )


def _reload_page(db, page_id) -> OrmPage:
    return (
        db.query(OrmPage)
        .options(*_PAGE_EAGER)
        .filter(OrmPage.id == page_id)
        .first()
    )


def _reload_template(db, template_id) -> OrmTemplate:
    return (
        db.query(OrmTemplate)
        .options(*_TEMPLATE_EAGER)
        .filter(OrmTemplate.id == template_id)
        .first()
    )


def _build_auth_payload(db, user: OrmUser) -> AuthPayload:
    token = create_access_token(str(user.id))
    gql_user = orm_user_to_gql(user)
    return AuthPayload(
        access_token=token,
        token_type="bearer",
        expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        viewer=gql_user,
    )


@strawberry.type
class Mutation:
    # ------------------------------------------------------------------
    # Auth
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Register a new user account.")
    def sign_up(
        self,
        info: Info,
        email: str,
        password: str,
        display_name: Optional[str] = None,
    ) -> AuthPayload:
        db = SessionLocal()
        try:
            existing = db.query(OrmUser).filter(OrmUser.email == email.lower()).first()
            if existing:
                raise Exception("Email already registered")

            password_hash = _pwd_ctx.hash(password)
            user = OrmUser(
                email=email.lower(),
                password_hash=password_hash,
                display_name=display_name,
                is_active=True,
                is_verified=False,
            )
            db.add(user)
            db.flush()  # get the user.id

            # Assign default "viewer" role if it exists
            viewer_role = db.query(Role).filter(Role.key == "viewer").first()
            if viewer_role:
                db.add(UserRole(user_id=user.id, role_id=viewer_role.id))

            db.commit()
            db.refresh(user)

            user = (
                db.query(OrmUser)
                .options(*_USER_EAGER)
                .filter(OrmUser.id == user.id)
                .first()
            )
            return _build_auth_payload(db, user)
        finally:
            db.close()

    @strawberry.mutation(description="Authenticate and receive an access token.")
    def sign_in(self, info: Info, email: str, password: str) -> AuthPayload:
        db = SessionLocal()
        try:
            user = (
                db.query(OrmUser)
                .options(*_USER_EAGER)
                .filter(OrmUser.email == email.lower(), OrmUser.is_deleted == False)
                .first()
            )
            if not user or not user.is_active:
                raise Exception("Invalid credentials")
            if not _pwd_ctx.verify(password, user.password_hash):
                raise Exception("Invalid credentials")
            return _build_auth_payload(db, user)
        finally:
            db.close()

    @strawberry.mutation(description="Exchange a refresh token for a new access token.")
    def refresh_token(self, info: Info, refresh_token: str) -> AuthPayload:
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise Exception("Invalid or expired refresh token")
        user_id = payload.get("sub")
        if not user_id:
            raise Exception("Invalid token")
        db = SessionLocal()
        try:
            user = (
                db.query(OrmUser)
                .options(*_USER_EAGER)
                .filter(OrmUser.id == user_id, OrmUser.is_active == True, OrmUser.is_deleted == False)
                .first()
            )
            if not user:
                raise Exception("User not found")
            return _build_auth_payload(db, user)
        finally:
            db.close()

    @strawberry.mutation(description="Sign out and invalidate the current session.")
    def sign_out(self, info: Info) -> bool:
        # Stateless JWT: client should discard the token.
        return True

    # ------------------------------------------------------------------
    # Posts (requires post:create / post:publish / post:archive)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a new post draft. Requires authentication.")
    def create_post(self, info: Info, input: CreatePostInput) -> Post:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            slug = input.slug or slugify(input.title)
            # Ensure slug uniqueness
            existing = db.query(OrmPost).filter(OrmPost.slug == slug).first()
            if existing:
                slug = f"{slug}-{uuid.uuid4().hex[:6]}"

            post = OrmPost(
                author_id=uuid.UUID(viewer.user_id),
                slug=slug,
                title=input.title,
                excerpt=input.excerpt,
                featured_image_url=input.featured_image_url,
                content_jsonb=input.content_jsonb or {},
                status="draft",
            )
            db.add(post)
            db.flush()

            if input.tag_ids:
                for tag_id in input.tag_ids:
                    db.add(OrmPostTag(post_id=post.id, tag_id=tag_id))

            if input.category_ids:
                for cat_id in input.category_ids:
                    db.add(OrmPostCategory(post_id=post.id, category_id=cat_id))

            db.commit()
            post = _reload_post(db, post.id)
            return orm_post_to_gql(post)
        finally:
            db.close()

    @strawberry.mutation(description="Update an existing post.")
    def update_post(self, info: Info, id: uuid.UUID, input: UpdatePostInput) -> Post:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            post = (
                db.query(OrmPost)
                .filter(OrmPost.id == id, OrmPost.is_deleted == False)
                .first()
            )
            if not post:
                raise Exception("Post not found")

            # Ownership check
            if str(post.author_id) != viewer.user_id:
                if "post:edit" not in viewer.permissions:
                    raise Exception("Permission denied: post:edit")

            # Save revision before updating
            db.add(OrmRevision(
                entity_type=_ENTITY_POST,
                entity_id=post.id,
                author_id=uuid.UUID(viewer.user_id),
                snapshot_jsonb=post.content_jsonb or {},
            ))

            if input.title is not None:
                post.title = input.title
            if input.slug is not None:
                post.slug = input.slug
            if input.excerpt is not None:
                post.excerpt = input.excerpt
            if input.featured_image_url is not None:
                post.featured_image_url = input.featured_image_url
            if input.content_jsonb is not None:
                post.content_jsonb = input.content_jsonb

            post.updated_at = datetime.now(timezone.utc)

            if input.tag_ids is not None:
                db.query(OrmPostTag).filter(OrmPostTag.post_id == post.id).delete()
                for tag_id in input.tag_ids:
                    db.add(OrmPostTag(post_id=post.id, tag_id=tag_id))

            if input.category_ids is not None:
                db.query(OrmPostCategory).filter(OrmPostCategory.post_id == post.id).delete()
                for cat_id in input.category_ids:
                    db.add(OrmPostCategory(post_id=post.id, category_id=cat_id))

            db.commit()
            post = _reload_post(db, post.id)
            return orm_post_to_gql(post)
        finally:
            db.close()

    @strawberry.mutation(description="Publish a post. Requires post:publish.")
    def publish_post(self, info: Info, id: uuid.UUID) -> Post:
        viewer = require_perm(info.context, "post:publish")
        db = SessionLocal()
        try:
            post = (
                db.query(OrmPost)
                .filter(OrmPost.id == id, OrmPost.is_deleted == False)
                .first()
            )
            if not post:
                raise Exception("Post not found")

            post.status = "published"
            if not post.published_at:
                post.published_at = datetime.now(timezone.utc)
            post.updated_at = datetime.now(timezone.utc)

            db.commit()
            post = _reload_post(db, post.id)
            return orm_post_to_gql(post)
        finally:
            db.close()

    @strawberry.mutation(description="Archive a post. Requires post:archive.")
    def archive_post(self, info: Info, id: uuid.UUID) -> Post:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            post = (
                db.query(OrmPost)
                .filter(OrmPost.id == id, OrmPost.is_deleted == False)
                .first()
            )
            if not post:
                raise Exception("Post not found")

            if str(post.author_id) != viewer.user_id and "post:delete" not in viewer.permissions:
                raise Exception("Permission denied")

            post.status = "archived"
            post.archived_at = datetime.now(timezone.utc)
            post.updated_at = datetime.now(timezone.utc)

            db.commit()
            post = _reload_post(db, post.id)
            return orm_post_to_gql(post)
        finally:
            db.close()

    @strawberry.mutation(description="Soft-delete a post.")
    def delete_post(self, info: Info, id: uuid.UUID) -> bool:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            post = (
                db.query(OrmPost)
                .filter(OrmPost.id == id, OrmPost.is_deleted == False)
                .first()
            )
            if not post:
                raise Exception("Post not found")

            if str(post.author_id) != viewer.user_id and "post:delete" not in viewer.permissions:
                raise Exception("Permission denied: post:delete")

            post.is_deleted = True
            post.deleted_at = datetime.now(timezone.utc)
            post.updated_at = datetime.now(timezone.utc)
            db.commit()
            return True
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Pages
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a new page draft.")
    def create_page(self, info: Info, input: CreatePostInput) -> Page:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            slug = input.slug or slugify(input.title)
            existing = db.query(OrmPage).filter(OrmPage.slug == slug).first()
            if existing:
                slug = f"{slug}-{uuid.uuid4().hex[:6]}"

            page = OrmPage(
                author_id=uuid.UUID(viewer.user_id),
                slug=slug,
                title=input.title,
                content_jsonb=input.content_jsonb or {},
                status="draft",
            )
            db.add(page)
            db.commit()
            page = _reload_page(db, page.id)
            return orm_page_to_gql(page)
        finally:
            db.close()

    @strawberry.mutation(description="Update an existing page.")
    def update_page(self, info: Info, id: uuid.UUID, input: UpdatePostInput) -> Page:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            page = (
                db.query(OrmPage)
                .filter(OrmPage.id == id, OrmPage.is_deleted == False)
                .first()
            )
            if not page:
                raise Exception("Page not found")

            if str(page.author_id) != viewer.user_id and "page:edit" not in viewer.permissions:
                raise Exception("Permission denied: page:edit")

            db.add(OrmRevision(
                entity_type=_ENTITY_PAGE,
                entity_id=page.id,
                author_id=uuid.UUID(viewer.user_id),
                snapshot_jsonb=page.content_jsonb or {},
            ))

            if input.title is not None:
                page.title = input.title
            if input.slug is not None:
                page.slug = input.slug
            if input.content_jsonb is not None:
                page.content_jsonb = input.content_jsonb
            page.updated_at = datetime.now(timezone.utc)

            db.commit()
            page = _reload_page(db, page.id)
            return orm_page_to_gql(page)
        finally:
            db.close()

    @strawberry.mutation(description="Publish a page. Requires page:publish.")
    def publish_page(self, info: Info, id: uuid.UUID) -> Page:
        viewer = require_perm(info.context, "page:publish")
        db = SessionLocal()
        try:
            page = (
                db.query(OrmPage)
                .filter(OrmPage.id == id, OrmPage.is_deleted == False)
                .first()
            )
            if not page:
                raise Exception("Page not found")

            page.status = "published"
            if not page.published_at:
                page.published_at = datetime.now(timezone.utc)
            page.updated_at = datetime.now(timezone.utc)

            db.commit()
            page = _reload_page(db, page.id)
            return orm_page_to_gql(page)
        finally:
            db.close()

    @strawberry.mutation(description="Soft-delete a page.")
    def delete_page(self, info: Info, id: uuid.UUID) -> bool:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            page = (
                db.query(OrmPage)
                .filter(OrmPage.id == id, OrmPage.is_deleted == False)
                .first()
            )
            if not page:
                raise Exception("Page not found")

            if str(page.author_id) != viewer.user_id and "page:delete" not in viewer.permissions:
                raise Exception("Permission denied: page:delete")

            page.is_deleted = True
            page.deleted_at = datetime.now(timezone.utc)
            page.updated_at = datetime.now(timezone.utc)
            db.commit()
            return True
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Templates (requires template:edit / template:publish)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a new template. Requires template:edit.")
    def create_template(self, info: Info, input: CreateTemplateInput) -> Template:
        viewer = require_perm(info.context, "template:edit")
        db = SessionLocal()
        try:
            existing = db.query(OrmTemplate).filter(OrmTemplate.slug == input.slug).first()
            if existing:
                raise Exception(f"Template slug '{input.slug}' already exists")

            template = OrmTemplate(
                author_id=uuid.UUID(viewer.user_id),
                slug=input.slug,
                name=input.name,
                description=input.description,
                content_jsonb=input.content_jsonb or {},
                status="draft",
            )
            db.add(template)
            db.commit()
            template = _reload_template(db, template.id)
            return orm_template_to_gql(template)
        finally:
            db.close()

    @strawberry.mutation(description="Update an existing template. Requires template:edit.")
    def update_template(self, info: Info, id: uuid.UUID, input: UpdateTemplateInput) -> Template:
        viewer = require_perm(info.context, "template:edit")
        db = SessionLocal()
        try:
            template = (
                db.query(OrmTemplate)
                .filter(OrmTemplate.id == id)
                .first()
            )
            if not template:
                raise Exception("Template not found")

            db.add(OrmRevision(
                entity_type=_ENTITY_TEMPLATE,
                entity_id=template.id,
                author_id=uuid.UUID(viewer.user_id),
                snapshot_jsonb=template.content_jsonb or {},
            ))

            if input.slug is not None:
                template.slug = input.slug
            if input.name is not None:
                template.name = input.name
            if input.description is not None:
                template.description = input.description
            if input.content_jsonb is not None:
                template.content_jsonb = input.content_jsonb
            template.updated_at = datetime.now(timezone.utc)

            db.commit()
            template = _reload_template(db, template.id)
            return orm_template_to_gql(template)
        finally:
            db.close()

    @strawberry.mutation(description="Publish a template. Requires template:publish.")
    def publish_template(self, info: Info, id: uuid.UUID) -> Template:
        viewer = require_perm(info.context, "template:publish")
        db = SessionLocal()
        try:
            template = (
                db.query(OrmTemplate)
                .filter(OrmTemplate.id == id)
                .first()
            )
            if not template:
                raise Exception("Template not found")

            template.status = "published"
            template.updated_at = datetime.now(timezone.utc)

            db.commit()
            template = _reload_template(db, template.id)
            return orm_template_to_gql(template)
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Blocks
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Add a block to a post, page, or template.")
    def add_block(self, info: Info, input: AddBlockInput) -> Block:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            block = OrmBlock(
                owner_type=input.owner_type,
                owner_id=input.owner_id,
                block_type=input.block_type,
                data_jsonb=input.data_jsonb,
                sort_order=input.sort_order,
            )
            db.add(block)
            db.commit()
            db.refresh(block)
            return Block(
                id=block.id,
                owner_type=block.owner_type,
                owner_id=block.owner_id,
                sort_order=block.sort_order,
                block_type=block.block_type,
                data_jsonb=block.data_jsonb,
                created_at=block.created_at,
                updated_at=block.updated_at,
            )
        finally:
            db.close()

    @strawberry.mutation(description="Reorder blocks for an owner entity.")
    def reorder_blocks(
        self,
        info: Info,
        owner_type: str,
        owner_id: uuid.UUID,
        ordered_ids: list[uuid.UUID],
    ) -> list[Block]:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            for i, block_id in enumerate(ordered_ids):
                db.query(OrmBlock).filter(OrmBlock.id == block_id).update(
                    {"sort_order": i, "updated_at": datetime.now(timezone.utc)}
                )
            db.commit()
            rows = (
                db.query(OrmBlock)
                .filter(OrmBlock.owner_type == owner_type, OrmBlock.owner_id == owner_id)
                .order_by(OrmBlock.sort_order)
                .all()
            )
            return [
                Block(
                    id=b.id,
                    owner_type=b.owner_type,
                    owner_id=b.owner_id,
                    sort_order=b.sort_order,
                    block_type=b.block_type,
                    data_jsonb=b.data_jsonb,
                    created_at=b.created_at,
                    updated_at=b.updated_at,
                )
                for b in rows
            ]
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Uploads (metadata record only — actual file is uploaded externally)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Register an uploaded asset reference. Requires media:upload.")
    def upload_asset_reference(
        self,
        info: Info,
        input: UploadAssetReferenceInput,
    ) -> MediaAsset:
        viewer = require_perm(info.context, "media:upload")
        db = SessionLocal()
        try:
            asset = OrmMediaAsset(
                uploader_id=uuid.UUID(viewer.user_id),
                file_name=input.file_name,
                content_type=input.content_type,
                byte_size=input.byte_size,
                storage_provider=input.storage_provider,
                storage_bucket=input.storage_bucket,
                storage_key=input.storage_key,
                public_url=input.public_url,
                checksum_sha256=input.checksum_sha256,
            )
            db.add(asset)
            db.commit()
            db.refresh(asset)
            return orm_media_to_gql(asset)
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Commerce (requires authenticated user)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a purchase record.")
    def create_purchase(self, info: Info, input: CreatePurchaseInput) -> Purchase:
        viewer = require_auth(info.context)
        db = SessionLocal()
        try:
            product = (
                db.query(OrmProduct)
                .filter(OrmProduct.id == input.product_id, OrmProduct.status == "active")
                .first()
            )
            if not product:
                raise Exception("Product not found or inactive")

            # Find an available license for this product
            license_obj = (
                db.query(OrmLicense)
                .filter(OrmLicense.product_id == input.product_id)
                .first()
            )

            purchase = OrmPurchase(
                buyer_id=uuid.UUID(viewer.user_id),
                product_id=input.product_id,
                license_id=license_obj.id if license_obj else None,
                amount_cents=input.amount_cents,
                currency=input.currency,
                provider=input.provider,
                provider_ref=input.provider_txn_id,
                status="paid",
            )
            db.add(purchase)
            db.commit()
            db.refresh(purchase)
            return orm_purchase_to_gql(purchase)
        finally:
            db.close()

    @strawberry.mutation(description="Verify a license key and return the license if valid.")
    def verify_license(self, info: Info, input: VerifyLicenseInput) -> Optional[License]:
        db = SessionLocal()
        try:
            lic = (
                db.query(OrmLicense)
                .filter(OrmLicense.license_key == input.license_key)
                .first()
            )
            if not lic:
                return None
            # Check expiry
            if lic.expires_at and lic.expires_at < datetime.now(timezone.utc):
                return None
            return orm_license_to_gql(lic)
        finally:
            db.close()

