"""
Rate-limit middleware.
Populated in Phase 3+ (Backend Core hardening).
"""

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Placeholder rate-limit middleware.  Replace with a Redis-backed
    sliding-window implementation in Phase 3."""

    async def dispatch(self, request: Request, call_next) -> Response:
        # TODO: implement token-bucket / sliding-window rate limiting
        return await call_next(request)
