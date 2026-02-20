import logging
import time
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

logger = logging.getLogger("caddystats.request")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start = time.time()
        response = await call_next(request)
        ms = int((time.time() - start) * 1000)
        logger.info("%s %s -> %s (%sms)", request.method, request.url.path, response.status_code, ms)
        return response
