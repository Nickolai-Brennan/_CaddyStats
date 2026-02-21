from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from strawberry.fastapi import GraphQLRouter
from sqlalchemy import text

from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.requests import Request
from app.middleware.exceptions import http_exception_handler, unhandled_exception_handler

from app.core.config import settings
from app.graphql.schema import schema
from app.api.graphql_router import get_context
from app.api.auth import router as auth_router
from app.api.media import router as media_router
from app.db.content import content_engine
from app.utils.logging import configure_logging
from app.middleware.request_logging import RequestLoggingMiddleware
from app.middleware.security_headers import SecurityHeadersMiddleware
from app.middleware.metrics import MetricsMiddleware
from app.middleware.rate_limit import apply_rate_limiting

configure_logging()
app = FastAPI(title="Caddy Stats API", version="0.1.0")
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(Exception, unhandled_exception_handler)
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(MetricsMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

apply_rate_limiting(app)

# Auth and media REST routes
app.include_router(auth_router, prefix="/api")
app.include_router(media_router, prefix="/api")

# GraphQL endpoint with auth context
if settings.app_env == "development":
    app.include_router(
        GraphQLRouter(schema, context_getter=get_context, graphql_ide="graphiql"),
        prefix="/graphql",
    )
else:
    app.include_router(GraphQLRouter(schema, context_getter=get_context), prefix="/graphql")


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


@app.get("/ready")
def ready():
    """Readiness probe: verifies database connectivity before accepting traffic."""
    try:
        with content_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
    except Exception as e:
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database not ready: {e}",
        )
    return {"ready": True}

