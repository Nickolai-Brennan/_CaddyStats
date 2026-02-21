"""
GraphQL Mutation resolvers.

All resolvers return stubs until the DB session layer is wired in.
RBAC guards are enforced via the viewer context (permission key checks).
"""

from __future__ import annotations

import uuid
from typing import Optional

import strawberry
from strawberry.types import Info

from app.graphql.types import (
    AddBlockInput,
    AuthPayload,
    Block,
    CreatePostInput,
    CreatePurchaseInput,
    CreateTemplateInput,
    License,
    MediaAsset,
    Post,
    Purchase,
    Template,
    UpdatePostInput,
    UpdateTemplateInput,
    UploadAssetReferenceInput,
    User,
    VerifyLicenseInput,
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
        # TODO: hash password, insert user, issue JWT
        raise NotImplementedError("signUp not yet implemented")

    @strawberry.mutation(description="Authenticate and receive an access token.")
    def sign_in(self, info: Info, email: str, password: str) -> AuthPayload:
        # TODO: verify credentials, issue JWT
        raise NotImplementedError("signIn not yet implemented")

    @strawberry.mutation(description="Exchange a refresh token for a new access token.")
    def refresh_token(self, info: Info, refresh_token: str) -> AuthPayload:
        # TODO: validate refresh token, issue new JWT
        raise NotImplementedError("refreshToken not yet implemented")

    @strawberry.mutation(description="Sign out and invalidate the current session.")
    def sign_out(self, info: Info) -> bool:
        # TODO: revoke token / clear session
        return True

    # ------------------------------------------------------------------
    # Posts (requires post:create / post:publish / post:archive)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a new post draft. Requires post:create.")
    def create_post(self, info: Info, input: CreatePostInput) -> Post:
        # TODO: RBAC check post:create, insert into website_content.posts
        raise NotImplementedError("createPost not yet implemented")

    @strawberry.mutation(description="Update an existing post. Requires post:create.")
    def update_post(self, info: Info, id: uuid.UUID, input: UpdatePostInput) -> Post:
        # TODO: RBAC check post:create, update post row
        raise NotImplementedError("updatePost not yet implemented")

    @strawberry.mutation(description="Publish a post. Requires post:publish.")
    def publish_post(self, info: Info, id: uuid.UUID) -> Post:
        # TODO: RBAC check post:publish, set status='published', published_at=now()
        raise NotImplementedError("publishPost not yet implemented")

    @strawberry.mutation(description="Archive a post. Requires post:archive.")
    def archive_post(self, info: Info, id: uuid.UUID) -> Post:
        # TODO: RBAC check post:archive, set status='archived'
        raise NotImplementedError("archivePost not yet implemented")

    # ------------------------------------------------------------------
    # Templates (requires template:edit / template:publish)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a new template. Requires template:edit.")
    def create_template(self, info: Info, input: CreateTemplateInput) -> Template:
        # TODO: RBAC check template:edit, insert into website_content.templates
        raise NotImplementedError("createTemplate not yet implemented")

    @strawberry.mutation(description="Update an existing template. Requires template:edit.")
    def update_template(self, info: Info, id: uuid.UUID, input: UpdateTemplateInput) -> Template:
        raise NotImplementedError("updateTemplate not yet implemented")

    @strawberry.mutation(description="Publish a template. Requires template:publish.")
    def publish_template(self, info: Info, id: uuid.UUID) -> Template:
        raise NotImplementedError("publishTemplate not yet implemented")

    # ------------------------------------------------------------------
    # Blocks
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Add a block to a post, page, or template.")
    def add_block(self, info: Info, input: AddBlockInput) -> Block:
        # TODO: insert into website_content.blocks
        raise NotImplementedError("addBlock not yet implemented")

    @strawberry.mutation(description="Reorder blocks for an owner entity.")
    def reorder_blocks(
        self,
        info: Info,
        owner_type: str,
        owner_id: uuid.UUID,
        ordered_ids: list[uuid.UUID],
    ) -> list[Block]:
        # TODO: update sort_order for each block id
        raise NotImplementedError("reorderBlocks not yet implemented")

    # ------------------------------------------------------------------
    # Uploads (metadata record only — actual file is uploaded externally)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Register an uploaded asset reference. Requires media:upload.")
    def upload_asset_reference(
        self,
        info: Info,
        input: UploadAssetReferenceInput,
    ) -> MediaAsset:
        # TODO: RBAC check media:upload, insert into website_content.media_assets
        raise NotImplementedError("uploadAssetReference not yet implemented")

    # ------------------------------------------------------------------
    # Commerce (requires commerce:manage or authenticated user)
    # ------------------------------------------------------------------

    @strawberry.mutation(description="Create a purchase record.")
    def create_purchase(self, info: Info, input: CreatePurchaseInput) -> Purchase:
        # TODO: validate product exists, insert purchase + optionally create license
        raise NotImplementedError("createPurchase not yet implemented")

    @strawberry.mutation(description="Verify a license key and return the license if valid.")
    def verify_license(self, info: Info, input: VerifyLicenseInput) -> Optional[License]:
        # TODO: look up license by key, check status and expiry
        raise NotImplementedError("verifyLicense not yet implemented")
