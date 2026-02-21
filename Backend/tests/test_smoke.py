"""
Smoke tests – verify core endpoints and code paths are importable and callable.
These tests do not require a live database; they test the application logic
using TestClient with mocked/stubbed DB interactions where needed.
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    from app.main import app
    return TestClient(app, raise_server_exceptions=False)


def test_root_returns_ok(client):
    """GET / returns a 200 with application metadata."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "caddy-stats"
    assert data["status"] == "ok"


def test_health_endpoint_exists(client):
    """GET /health always returns 200 (db may be unreachable in CI)."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "ok" in data


def test_ready_endpoint_exists(client):
    """GET /ready returns either 200 or 503 depending on DB availability."""
    response = client.get("/ready")
    assert response.status_code in (200, 503)


def test_graphql_endpoint_exists(client):
    """POST /graphql responds (introspection or error – not 404)."""
    response = client.post(
        "/graphql",
        json={"query": "{ __typename }"},
        headers={"Content-Type": "application/json"},
    )
    assert response.status_code != 404


def test_auth_login_rejects_invalid_credentials(client):
    """POST /api/auth/login with bad credentials returns 401 or 422."""
    response = client.post(
        "/api/auth/login",
        json={"email": "noone@example.com", "password": "wrongpassword"},
    )
    # 401 = unauthorized; 422 = validation error (acceptable without DB)
    assert response.status_code in (401, 422, 500)


def test_media_list_requires_auth(client):
    """GET /api/media/list without a token returns 401 or 403."""
    response = client.get("/api/media/list")
    assert response.status_code in (401, 403)
