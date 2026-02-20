from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from strawberry.fastapi import GraphQLRouter
from sqlalchemy import text

from app.core.config import settings
from app.graphql.schema import schema
from app.db.content import content_engine
from app.db.stats import stats_engine

app = FastAPI(title="Caddy Stats API", version="0.1.0")

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
        # DB smoke tests (both engines must connect)
        with content_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        with stats_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_ok = True
    except Exception as e:
        print(f"DB Error: {e}")
        pass

    return {"ok": True, "db": db_ok}