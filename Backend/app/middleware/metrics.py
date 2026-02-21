"""
In-memory metrics middleware.
Tracks request counts, latency, and status code buckets per endpoint.
"""

from __future__ import annotations

import time
from collections import defaultdict
from typing import Dict, List

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

# Global in-memory metrics store
_request_count: Dict[str, int] = defaultdict(int)
_status_counts: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))
_latencies: Dict[str, List[float]] = defaultdict(list)


def get_metrics() -> dict:
    """Return a snapshot of all collected metrics."""
    result: dict = {}
    for path, count in _request_count.items():
        latency_list = _latencies.get(path, [])
        sorted_latencies = sorted(latency_list)
        n = len(sorted_latencies)

        def _pct(p: float) -> float | None:
            if not sorted_latencies:
                return None
            idx = min(len(sorted_latencies) - 1, int(n * p))
            return round(sorted_latencies[idx], 4)

        result[path] = {
            "total_requests": count,
            "status_codes": dict(_status_counts.get(path, {})),
            "latency_p50_s": _pct(0.50),
            "latency_p95_s": _pct(0.95),
            "latency_p99_s": _pct(0.99),
        }
    return result


class MetricsMiddleware(BaseHTTPMiddleware):
    """Collect per-endpoint request count, status codes, and latency."""

    async def dispatch(self, request: Request, call_next) -> Response:
        start = time.perf_counter()
        response = await call_next(request)
        elapsed = time.perf_counter() - start

        path = request.url.path
        status_bucket = f"{response.status_code // 100}xx"

        _request_count[path] += 1
        _status_counts[path][status_bucket] += 1
        _latencies[path].append(elapsed)

        # Keep only the last 1000 samples per path to bound memory usage
        if len(_latencies[path]) > 1000:
            _latencies[path] = _latencies[path][-1000:]

        return response
