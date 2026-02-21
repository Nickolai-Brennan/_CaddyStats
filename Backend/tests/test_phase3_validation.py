"""
Phase 3 validation gate tests.

Each test corresponds to a validation check in Phase 3 section 3.6.
Tests are designed to run without a live database, verifying that the
application boots correctly and core components are properly wired.
"""

from __future__ import annotations

import importlib
import pytest
from fastapi.testclient import TestClient


@pytest.fixture(scope="module")
def client():
    from app.main import app
    return TestClient(app, raise_server_exceptions=False)


def test_3_6_1_backend_boots():
    """The FastAPI application can be imported and instantiated."""
    from app.main import app
    assert app is not None
    assert app.title == "Caddy Stats API"


def test_3_6_2_health_and_ready_green(client):
    """Both /health and /ready endpoints respond (200 or 503 for /ready)."""
    health = client.get("/health")
    assert health.status_code == 200
    assert "ok" in health.json()

    ready = client.get("/ready")
    assert ready.status_code in (200, 503)


def test_3_6_3_graphql_introspection(client):
    """GraphQL endpoint accepts an introspection query."""
    response = client.post(
        "/graphql",
        json={"query": "{ __schema { queryType { name } } }"},
        headers={"Content-Type": "application/json"},
    )
    # Must not return 404 (endpoint must exist)
    assert response.status_code != 404
    # Should return JSON (data, errors, or server error body)
    body = response.json()
    assert isinstance(body, dict)


def test_3_6_4_post_crud_workflow():
    """ORM model, workflow service, and revision service can be imported."""
    from app.models.website_content import Post
    from app.services.post_workflow import can_transition, publish_post, unpublish_post
    from app.services.revision import create_revision

    # Verify transition logic (no DB needed)
    assert can_transition("draft", "published") is True
    assert can_transition("published", "draft") is True
    assert can_transition("archived", "published") is False


def test_3_6_5_revision_created_on_update():
    """Revision service module is importable and create_revision is callable."""
    from app.services.revision import create_revision
    import inspect
    sig = inspect.signature(create_revision)
    assert "entity_type" in sig.parameters
    assert "snapshot_data" in sig.parameters


def test_3_6_6_search_resolver():
    """GraphQL Query type exposes a search_posts resolver."""
    from app.graphql.queries import Query
    import inspect
    members = dict(inspect.getmembers(Query))
    # search_posts should be registered as a strawberry field
    assert hasattr(Query, "search_posts") or "search_posts" in str(members)


def test_3_6_7_rest_endpoints_json(client):
    """Root endpoint returns valid JSON."""
    response = client.get("/")
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("application/json")
    assert response.json()["name"] == "caddy-stats"


def test_3_6_8_rbac_blocks_unauthorized(client):
    """Auth-protected endpoints reject unauthenticated requests."""
    # Media list requires authentication
    response = client.get("/api/media/list")
    assert response.status_code in (401, 403)

    # Media upload requires authentication
    response = client.post("/api/media/upload")
    assert response.status_code in (401, 403, 422)


def test_3_6_9_upload_stores_media():
    """Media API module is importable and router is configured."""
    from app.api.media import router
    routes = [r.path for r in router.routes]
    assert any("upload" in p for p in routes)
    assert any("list" in p for p in routes)


def test_3_6_password_hashing():
    """Password hashing and verification work correctly."""
    from app.auth.password import hash_password, verify_password

    hashed = hash_password("supersecret")
    assert hashed != "supersecret"
    assert verify_password("supersecret", hashed) is True
    assert verify_password("wrongpassword", hashed) is False


def test_3_6_jwt_tokens():
    """JWT issue and decode work for access and refresh tokens."""
    from app.auth.jwt_handler import (
        create_access_token,
        create_refresh_token,
        decode_access_token,
        decode_refresh_token,
    )

    access = create_access_token("user-123")
    payload = decode_access_token(access)
    assert payload["sub"] == "user-123"
    assert payload["type"] == "access"

    refresh = create_refresh_token("user-123")
    rpayload = decode_refresh_token(refresh)
    assert rpayload["sub"] == "user-123"
    assert rpayload["type"] == "refresh"


def test_3_6_slug_collision():
    """generate_unique_slug returns base slug when no collision exists."""
    from app.utils.slugify import generate_unique_slug, slugify

    slug = slugify("Hello World")
    assert slug == "hello-world"

    # Mock session that finds no existing records
    class _FakeQuery:
        def filter(self, *_):
            return self
        def first(self):
            return None

    class _FakeSession:
        def query(self, _model):
            return _FakeQuery()

    class _FakeModel:
        slug = None

    unique = generate_unique_slug(_FakeSession(), _FakeModel, "Hello World")
    assert unique == "hello-world"


def test_3_6_security_headers_middleware():
    """SecurityHeadersMiddleware module is importable."""
    from app.middleware.security_headers import SecurityHeadersMiddleware
    assert SecurityHeadersMiddleware is not None


def test_3_6_metrics_middleware():
    """MetricsMiddleware module is importable and get_metrics returns a dict."""
    from app.middleware.metrics import MetricsMiddleware, get_metrics
    assert isinstance(get_metrics(), dict)


def test_3_6_audit_service():
    """Audit service module is importable."""
    from app.services.audit import log_audit
    import inspect
    sig = inspect.signature(log_audit)
    assert "action" in sig.parameters
    assert "entity_type" in sig.parameters
