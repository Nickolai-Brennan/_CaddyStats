# Backend/app/graphql/mutations.py
from __future__ import annotations

import strawberry
from strawberry.types import Info

from sqlalchemy import text

from app.db.session import SessionLocal
from app.graphql.context import GQLContext, require_perm


@strawberry.type
class Mutation:
    @strawberry.mutation
    def publish_post(self, info: Info[GQLContext, None], post_id: str) -> bool:
        require_perm(info.context, "post:publish")

        db = SessionLocal()
        try:
            db.execute(
                text("""
                    UPDATE website_content.posts
                    SET status = 'published',
                        published_at = now(),
                        updated_at = now()
                    WHERE id = :post_id::uuid AND is_deleted = false
                """),
                {"post_id": post_id},
            )
            db.commit()
            return True
        finally:
            db.close()
