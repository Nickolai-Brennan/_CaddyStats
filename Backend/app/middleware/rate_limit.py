"""
Rate-limit helpers using slowapi (wraps limits library).

Usage
-----
Import ``limiter`` and apply ``@limiter.limit("10/minute")`` to route handlers,
or use the :func:`apply_rate_limiting` helper to attach the slowapi middleware
to a FastAPI application instance.
"""

from slowapi import Limiter
from slowapi.util import get_remote_address

# One global limiter instance; keyed by client IP by default.
limiter = Limiter(key_func=get_remote_address)


def apply_rate_limiting(app) -> None:
    """Attach slowapi state and error handler to *app*."""
    from slowapi import _rate_limit_exceeded_handler
    from slowapi.errors import RateLimitExceeded
    from slowapi.middleware import SlowAPIMiddleware

    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
    app.add_middleware(SlowAPIMiddleware)

