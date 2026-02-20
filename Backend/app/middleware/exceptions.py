import logging
from typing import cast
from starlette.exceptions import HTTPException as StarletteHTTPException
from starlette.requests import Request
from starlette.responses import JSONResponse

logger = logging.getLogger("caddystats.exceptions")


async def http_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    exc = cast(StarletteHTTPException, exc)
    # Standardize HTTP errors
    logger.warning("HTTPException %s %s -> %s", request.method, request.url.path, exc.status_code)
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "type": "http_error",
                "status": exc.status_code,
                "detail": exc.detail,
                "path": request.url.path,
            }
        },
    )


async def unhandled_exception_handler(request: Request, exc: Exception):
    # Never leak internals to clients
    logger.exception("Unhandled error on %s %s", request.method, request.url.path)
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "type": "server_error",
                "status": 500,
                "detail": "Internal Server Error",
                "path": request.url.path,
            }
        },
    )
