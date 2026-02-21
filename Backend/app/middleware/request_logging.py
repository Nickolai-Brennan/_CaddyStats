import logging
import time
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

logger = logging.getLogger("caddystats.request")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())
        start = time.time()
        response = await call_next(request)
        ms = int((time.time() - start) * 1000)
        logger.info(
            "%s %s -> %s (%sms) request_id=%s",
            request.method,
            request.url.path,
            response.status_code,
            ms,
            request_id,
        )
        response.headers["X-Request-ID"] = request_id
        return response
