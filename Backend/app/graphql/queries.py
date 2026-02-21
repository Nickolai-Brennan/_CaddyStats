"""
GraphQL Query resolvers.

All resolvers return stubs until the DB session layer is wired in.
RBAC guards are enforced via the viewer context.
"""

from __future__ import annotations

import uuid
from typing import List, Optional

import strawberry
from strawberry.types import Info

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


@strawberry.type
class Query:
    # ------------------------------------------------------------------
    # Viewer
    # ------------------------------------------------------------------

    @strawberry.field(description="Returns the currently authenticated user.")
    def viewer(self, info: Info) -> Optional[User]:
        # TODO: decode JWT from info.context.request, load user from DB
        return None

    # ------------------------------------------------------------------
    # Users
    # ------------------------------------------------------------------

    @strawberry.field(description="List all users. Requires user:manage permission.")
    def users(self, info: Info) -> List[User]:
        # TODO: RBAC check for user:manage, load from DB
        return []

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
        # TODO: query website_content.posts with filter/sort/cursor
        return []

    @strawberry.field(description="Fetch a single post by slug.")
    def post(self, info: Info, slug: str) -> Optional[Post]:
        # TODO: load from DB
        return None

    @strawberry.field(description="Full-text search across posts.")
    def search_posts(
        self,
        info: Info,
        query: str,
        first: int = 20,
    ) -> List[Post]:
        # TODO: use posts.search_vector GIN index
        return []

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
        return []

    @strawberry.field(description="Fetch a single page by slug.")
    def page(self, info: Info, slug: str) -> Optional[Page]:
        return None

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
        return []

    @strawberry.field(description="Fetch a single template by slug.")
    def template(self, info: Info, slug: str) -> Optional[Template]:
        return None

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
        return []

    @strawberry.field(description="Fetch a single product by slug.")
    def product(self, info: Info, slug: str) -> Optional[Product]:
        return None

    @strawberry.field(description="Full-text search across products.")
    def search_products(
        self,
        info: Info,
        query: str,
        first: int = 20,
    ) -> List[Product]:
        # TODO: use products.search_vector GIN index
        return []

    # ------------------------------------------------------------------
    # Navigation
    # ------------------------------------------------------------------

    @strawberry.field(description="Fetch a nav menu by slug.")
    def nav_menu(self, info: Info, slug: str) -> Optional[NavMenu]:
        return None

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
