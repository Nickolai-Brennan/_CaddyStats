# Backend/app/graphql/queries.py
from __future__ import annotations

import strawberry
from strawberry.types import Info
from typing import Optional

from app.db.session import SessionLocal
from app.db.repos.posts_repo import list_posts
from app.graphql.context import decode_cursor, encode_cursor, GQLContext
from app.graphql.inputs.post_inputs import PostFilterInput, PostSortInput
from app.graphql.types.post import Post
from app.graphql.types.pagination import Connection, Edge, PageInfo


@strawberry.type
class Query:
    @strawberry.field
    def ping(self) -> str:
        return "pong"

    @strawberry.field
    def posts(
        self,
        info: Info[GQLContext, None],
        first: int = 10,
        after: Optional[str] = None,
        filter: Optional[PostFilterInput] = None,
        sort: Optional[PostSortInput] = None,
    ) -> Connection[Post]:
        # clamp
        first = max(1, min(first, 50))

        after_created_at = None
        after_id = None
        if after:
            after_created_at, after_id = decode_cursor(after)

        status = filter.status if filter else None

        db = SessionLocal()
        try:
            rows = list_posts(db, first=first, after_created_at=after_created_at, after_id=after_id, status=status)
        finally:
            db.close()

        has_next_page = len(rows) > first
        rows = rows[:first]

        edges = []
        end_cursor = None

        for (id_, title, slug, status_, created_at_iso) in rows:
            cursor = encode_cursor(created_at_iso, id_)
            end_cursor = cursor
            edges.append(
                Edge(
                    cursor=cursor,
                    node=Post(
                        id=id_,
                        title=title,
                        slug=slug,
                        status=status_,
                        created_at=created_at_iso,
                    ),
                )
            )

        return Connection(
            edges=edges,
            page_info=PageInfo(has_next_page=has_next_page, end_cursor=end_cursor),
        )
