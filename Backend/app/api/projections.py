"""
Projections REST endpoint.
Populated in Phase 3+ (Backend Core – Stats API).
"""

from fastapi import APIRouter

router = APIRouter(prefix="/projections", tags=["projections"])


@router.get("/{tournament_id}")
async def get_projections(tournament_id: str) -> dict:
    """Return projection data for the given tournament."""
    # TODO: delegate to stat_service
    return {"tournament_id": tournament_id, "data": []}
