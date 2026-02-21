"""
Leaderboard REST endpoint.
Populated in Phase 3+ (Backend Core – Stats API).
"""

from fastapi import APIRouter

router = APIRouter(prefix="/leaderboard", tags=["leaderboard"])


@router.get("/{tournament_id}")
async def get_leaderboard(tournament_id: str) -> dict:
    """Return leaderboard data for the given tournament."""
    # TODO: delegate to stat_service
    return {"tournament_id": tournament_id, "data": []}
