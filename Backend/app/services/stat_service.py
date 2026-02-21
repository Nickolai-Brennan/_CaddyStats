"""
Stat service – orchestrates calls to the external Stats API.
Populated in Phase 3+ (Backend Core – Stats API).
"""

from app.services import stats_api_client


async def get_leaderboard(tournament_id: str) -> dict:
    """Fetch leaderboard from the Stats API."""
    return await stats_api_client.get_leaderboard(tournament_id)


async def get_projections(tournament_id: str) -> dict:
    """Fetch projections from the Stats API."""
    # TODO: replace with stats_api_client.get_projections once endpoint exists
    return await stats_api_client.get_tournament_card(tournament_id)
