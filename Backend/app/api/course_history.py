"""
Course history REST endpoint.
Populated in Phase 3+ (Backend Core – Stats API).
"""

from fastapi import APIRouter

router = APIRouter(prefix="/course-history", tags=["course-history"])


@router.get("/{course_id}")
async def get_course_history(course_id: str) -> dict:
    """Return historical results for the given course."""
    # TODO: delegate to stat_service
    return {"course_id": course_id, "data": []}
