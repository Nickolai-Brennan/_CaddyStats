# Backend/app/api/graphql_router.py
from __future__ import annotations

from fastapi import APIRouter, Request
from strawberry.fastapi import GraphQLRouter

from app.graphql.schema import schema
from app.graphql.context import GQLContext, Viewer

router = APIRouter()

async def get_context(request: Request) -> GQLContext:
    # TODO: replace with real JWT decode + DB lookup
    # minimal stub: if Authorization header exists, treat as logged in.
    auth = request.headers.get("authorization")

    if not auth:
        return GQLContext(viewer=None)

    # TODO: build from token claims + DB
    return GQLContext(
        viewer=Viewer(
            user_id="00000000-0000-0000-0000-000000000000",
            roles={"admin"},
            permissions={"post:publish"},
        )
    )

graphql_app = GraphQLRouter(schema, context_getter=get_context)
router.include_router(graphql_app, prefix="/graphql")
