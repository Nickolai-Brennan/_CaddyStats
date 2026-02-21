"""
Betting edges REST endpoint.
Populated in Phase 3+ (Backend Core – Stats API).
"""

from fastapi import APIRouter

router = APIRouter(prefix="/betting-edges", tags=["betting-edges"])


@router.get("/{tournament_id}")
async def get_betting_edges(tournament_id: str) -> dict:
    """Return betting edge data for the given tournament."""
    # TODO: delegate to stat_service
    return {"tournament_id": tournament_id, "data": []}
