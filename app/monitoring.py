import time

from fastapi import Request
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response


REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["method", "path"],
)


async def metrics_middleware(request: Request, call_next):
    start = time.time()
    response = await call_next(request)

    REQUEST_COUNT.labels(
        request.method,
        request.url.path,
        response.status_code,
    ).inc()

    REQUEST_DURATION.labels(
        request.method,
        request.url.path,
    ).observe(time.time() - start)

    return response


def metrics():
    return Response(
        generate_latest(),
        media_type="text/plain",
    )