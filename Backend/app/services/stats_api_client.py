"""
Thin HTTP gateway to the external Stats API.

No local golf-stats tables exist in this database. All stats data is
fetched from the external Stats API and optionally cached (Redis layer TBD).
"""

import logging
from typing import Any

import httpx

from app.core.config import settings

logger = logging.getLogger("caddystats.stats_api")

_BASE = settings.stats_api_url.rstrip("/")
_TIMEOUT = settings.stats_api_timeout


async def _get(path: str) -> Any:
    """Issue a GET request to the Stats API; raises on HTTP error."""
    url = f"{_BASE}{path}"
    async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
        try:
            response = await client.get(url)
            response.raise_for_status()
            return response.json()
        except httpx.TimeoutException:
            logger.warning("Stats API timeout: %s", url)
            raise
        except httpx.HTTPStatusError as exc:
            logger.warning("Stats API HTTP error %s: %s", exc.response.status_code, url)
            raise


async def get_leaderboard(tournament_id: str) -> Any:
    """Return leaderboard data for the given tournament."""
    return await _get(f"/tournaments/{tournament_id}/leaderboard")


async def get_featured_edges(tournament_id: str) -> Any:
    """Return featured player edges (pairings/highlights) for the given tournament."""
    return await _get(f"/tournaments/{tournament_id}/featured-edges")


async def get_tournament_card(tournament_id: str) -> Any:
    """Return summary card metadata for the given tournament."""
    return await _get(f"/tournaments/{tournament_id}/card")
