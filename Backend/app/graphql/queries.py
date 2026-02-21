"""
GraphQL Query resolvers.

All resolvers return real data from PostgreSQL via SQLAlchemy ORM.
RBAC guards are enforced via the viewer context.
"""

from __future__ import annotations

import logging
import uuid
from typing import List, Optional

import strawberry
from sqlalchemy.orm import joinedload
from strawberry.types import Info

from app.db.session import SessionLocal
from app.graphql.context import GQLContext, require_perm
from app.graphql.converters import (
    orm_nav_menu_to_gql,
    orm_page_to_gql,
    orm_post_to_gql,
    orm_product_to_gql,
    orm_template_to_gql,
    orm_user_to_gql,
)
from app.graphql.types import (
    Category,
    Event,
    FeaturedEdge,
    LeaderboardEntry,
    MediaAsset,
    NavMenu,
    Page,
    Post,
    PostFilterInput,
    Product,
    ProductFilterInput,
    SortInput,
    Template,
    TournamentCard,
    User,
)
from app.models.website_content import (
    NavMenu as OrmNavMenu,
    NavItem as OrmNavItem,
    Page as OrmPage,
    Post as OrmPost,
    PostCategory as OrmPostCategory,
    PostTag as OrmPostTag,
    Product as OrmProduct,
    Role,
    RolePermission,
    Template as OrmTemplate,
    User as OrmUser,
    UserRole,
)

logger = logging.getLogger("caddystats.queries")

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


@strawberry.type
class Query:
    # ------------------------------------------------------------------
    # Viewer
    # ------------------------------------------------------------------

    @strawberry.field(description="Returns the currently authenticated user.")
    def viewer(self, info: Info) -> Optional[User]:
        if not info.context.viewer:
            return None
        db = SessionLocal()
        try:
            user = (
                db.query(OrmUser)
                .options(
                    joinedload(OrmUser.user_roles)
                    .joinedload(UserRole.role)
                    .joinedload(Role.role_permissions)
                    .joinedload(RolePermission.permission)
                )
                .filter(
                    OrmUser.id == info.context.viewer.user_id,
                    OrmUser.is_deleted == False,
                )
                .first()
            )
            return orm_user_to_gql(user) if user else None
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Users
    # ------------------------------------------------------------------

    @strawberry.field(description="List all users. Requires user:manage permission.")
    def users(self, info: Info) -> List[User]:
        require_perm(info.context, "user:manage")
        db = SessionLocal()
        try:
            rows = (
                db.query(OrmUser)
                .options(
                    joinedload(OrmUser.user_roles)
                    .joinedload(UserRole.role)
                    .joinedload(Role.role_permissions)
                    .joinedload(RolePermission.permission)
                )
                .filter(OrmUser.is_deleted == False)
                .order_by(OrmUser.created_at.desc())
                .all()
            )
            return [orm_user_to_gql(u) for u in rows]
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Posts
    # ------------------------------------------------------------------

    @strawberry.field(description="Paginated list of posts.")
    def posts(
        self,
        info: Info,
        filter: Optional[PostFilterInput] = None,
        sort: Optional[SortInput] = None,
        first: int = 20,
        after: Optional[str] = None,
    ) -> List[Post]:
        db = SessionLocal()
        try:
            q = (
                db.query(OrmPost)
                .options(*_POST_EAGER)
                .filter(OrmPost.is_deleted == False)
            )
            if filter:
                if filter.status:
                    q = q.filter(OrmPost.status == filter.status)
                if filter.author_id:
                    q = q.filter(OrmPost.author_id == filter.author_id)
                if filter.tag_ids:
                    q = q.join(OrmPost.post_tags).filter(
                        OrmPostTag.tag_id.in_(filter.tag_ids)
                    )
                if filter.category_ids:
                    q = q.join(OrmPost.post_categories).filter(
                        OrmPostCategory.category_id.in_(filter.category_ids)
                    )

            sort_field = OrmPost.created_at
            if sort:
                field_map = {
                    "CREATED_AT": OrmPost.created_at,
                    "UPDATED_AT": OrmPost.updated_at,
                    "PUBLISHED_AT": OrmPost.published_at,
                    "TITLE": OrmPost.title,
                }
                sort_field = field_map.get(sort.field.upper(), OrmPost.created_at)

            if sort and sort.direction.upper() == "ASC":
                q = q.order_by(sort_field.asc())
            else:
                q = q.order_by(sort_field.desc())

            first = max(1, min(first, 100))
            rows = q.limit(first).all()
            return [orm_post_to_gql(p) for p in rows]
        finally:
            db.close()

    @strawberry.field(description="Fetch a single post by slug.")
    def post(self, info: Info, slug: str) -> Optional[Post]:
        db = SessionLocal()
        try:
            p = (
                db.query(OrmPost)
                .options(*_POST_EAGER)
                .filter(OrmPost.slug == slug, OrmPost.is_deleted == False)
                .first()
            )
            return orm_post_to_gql(p) if p else None
        finally:
            db.close()

    @strawberry.field(description="Full-text search across posts.")
    def search_posts(
        self,
        info: Info,
        query: str,
        first: int = 20,
    ) -> List[Post]:
        db = SessionLocal()
        try:
            from sqlalchemy import func
            first = max(1, min(first, 100))
            rows = (
                db.query(OrmPost)
                .options(*_POST_EAGER)
                .filter(
                    OrmPost.is_deleted == False,
                    OrmPost.search_vector.op("@@")(
                        func.to_tsquery("english", query)
                    ),
                )
                .order_by(
                    func.ts_rank(OrmPost.search_vector, func.to_tsquery("english", query)).desc()
                )
                .limit(first)
                .all()
            )
            return [orm_post_to_gql(p) for p in rows]
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Pages
    # ------------------------------------------------------------------

    @strawberry.field(description="Paginated list of pages.")
    def pages(
        self,
        info: Info,
        first: int = 20,
        after: Optional[str] = None,
    ) -> List[Page]:
        db = SessionLocal()
        try:
            first = max(1, min(first, 100))
            rows = (
                db.query(OrmPage)
                .options(*_PAGE_EAGER)
                .filter(OrmPage.is_deleted == False)
                .order_by(OrmPage.created_at.desc())
                .limit(first)
                .all()
            )
            return [orm_page_to_gql(p) for p in rows]
        finally:
            db.close()

    @strawberry.field(description="Fetch a single page by slug.")
    def page(self, info: Info, slug: str) -> Optional[Page]:
        db = SessionLocal()
        try:
            p = (
                db.query(OrmPage)
                .options(*_PAGE_EAGER)
                .filter(OrmPage.slug == slug, OrmPage.is_deleted == False)
                .first()
            )
            return orm_page_to_gql(p) if p else None
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Templates
    # ------------------------------------------------------------------

    @strawberry.field(description="Paginated list of templates.")
    def templates(
        self,
        info: Info,
        first: int = 20,
        after: Optional[str] = None,
    ) -> List[Template]:
        db = SessionLocal()
        try:
            first = max(1, min(first, 100))
            rows = (
                db.query(OrmTemplate)
                .options(*_TEMPLATE_EAGER)
                .order_by(OrmTemplate.created_at.desc())
                .limit(first)
                .all()
            )
            return [orm_template_to_gql(t) for t in rows]
        finally:
            db.close()

    @strawberry.field(description="Fetch a single template by slug.")
    def template(self, info: Info, slug: str) -> Optional[Template]:
        db = SessionLocal()
        try:
            t = (
                db.query(OrmTemplate)
                .options(*_TEMPLATE_EAGER)
                .filter(OrmTemplate.slug == slug)
                .first()
            )
            return orm_template_to_gql(t) if t else None
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Products
    # ------------------------------------------------------------------

    @strawberry.field(description="Paginated list of products.")
    def products(
        self,
        info: Info,
        filter: Optional[ProductFilterInput] = None,
        sort: Optional[SortInput] = None,
        first: int = 20,
        after: Optional[str] = None,
    ) -> List[Product]:
        db = SessionLocal()
        try:
            first = max(1, min(first, 100))
            q = db.query(OrmProduct)
            if filter:
                if filter.status:
                    q = q.filter(OrmProduct.status == filter.status)
                if filter.product_type:
                    q = q.filter(OrmProduct.product_type == filter.product_type)
            q = q.order_by(OrmProduct.created_at.desc()).limit(first)
            return [orm_product_to_gql(p) for p in q.all()]
        finally:
            db.close()

    @strawberry.field(description="Fetch a single product by slug.")
    def product(self, info: Info, slug: str) -> Optional[Product]:
        db = SessionLocal()
        try:
            p = db.query(OrmProduct).filter(OrmProduct.slug == slug).first()
            return orm_product_to_gql(p) if p else None
        finally:
            db.close()

    @strawberry.field(description="Full-text search across products.")
    def search_products(
        self,
        info: Info,
        query: str,
        first: int = 20,
    ) -> List[Product]:
        db = SessionLocal()
        try:
            from sqlalchemy import func
            first = max(1, min(first, 100))
            rows = (
                db.query(OrmProduct)
                .filter(
                    OrmProduct.search_vector.op("@@")(
                        func.to_tsquery("english", query)
                    )
                )
                .limit(first)
                .all()
            )
            return [orm_product_to_gql(p) for p in rows]
        finally:
            db.close()

    # ------------------------------------------------------------------
    # Navigation
    # ------------------------------------------------------------------

    @strawberry.field(description="Fetch a nav menu by slug.")
    def nav_menu(self, info: Info, slug: str) -> Optional[NavMenu]:
        db = SessionLocal()
        try:
            m = (
                db.query(OrmNavMenu)
                .options(
                    joinedload(OrmNavMenu.items).joinedload(OrmNavItem.children)
                )
                .filter(OrmNavMenu.slug == slug)
                .first()
            )
            return orm_nav_menu_to_gql(m) if m else None
        finally:
            db.close()

    # ------------------------------------------------------------------
    # External Stats API gateway (no local stats DB)
    # ------------------------------------------------------------------

    @strawberry.field(description="Leaderboard for a tournament (proxied from Stats API).")
    async def leaderboard(
        self,
        info: Info,
        tournament_id: str,
    ) -> List[LeaderboardEntry]:
        from app.services import stats_api_client
        try:
            data = await stats_api_client.get_leaderboard(tournament_id)
            return [
                LeaderboardEntry(
                    position=entry.get("position", 0),
                    player_name=entry.get("playerName", ""),
                    score=entry.get("score"),
                    raw=entry,
                )
                for entry in (data if isinstance(data, list) else [])
            ]
        except Exception:
            return []

    @strawberry.field(description="Featured player edges for a tournament (proxied from Stats API).")
    async def featured_edges(
        self,
        info: Info,
        tournament_id: str,
    ) -> List[FeaturedEdge]:
        from app.services import stats_api_client
        try:
            data = await stats_api_client.get_featured_edges(tournament_id)
            return [
                FeaturedEdge(player_name=e.get("playerName", ""), raw=e)
                for e in (data if isinstance(data, list) else [])
            ]
        except Exception:
            return []

    @strawberry.field(description="Summary card for a tournament (proxied from Stats API).")
    async def tournament_card(
        self,
        info: Info,
        tournament_id: str,
    ) -> Optional[TournamentCard]:
        from app.services import stats_api_client
        try:
            data = await stats_api_client.get_tournament_card(tournament_id)
            return TournamentCard(
                tournament_id=tournament_id,
                name=data.get("name") if isinstance(data, dict) else None,
                raw=data,
            )
        except Exception:
            return None

