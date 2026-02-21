from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from strawberry.fastapi import GraphQLRouter
from sqlalchemy import text

from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.requests import Request
from app.middleware.exceptions import http_exception_handler, unhandled_exception_handler

from app.core.config import settings
from app.graphql.schema import schema
from app.db.content import content_engine
from app.utils.logging import configure_logging
from app.middleware.request_logging import RequestLoggingMiddleware

configure_logging()
app = FastAPI(title="Caddy Stats API", version="0.1.0")
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, unhandled_exception_handler)
app.add_middleware(RequestLoggingMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# GraphQL endpoint
app.include_router(GraphQLRouter(schema), prefix="/graphql")


@app.get("/")
def root():
    return {"name": "caddy-stats", "env": settings.app_env, "status": "ok"}


@app.get("/health")
def health():
    db_ok = False
    try:
        with content_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_ok = True
    except Exception as e:
        print(f"DB Error: {e}")

    return {"ok": True, "db": db_ok}