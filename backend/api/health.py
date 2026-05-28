"""Health route boundary."""

from fastapi import APIRouter

from backend.services.health import build_health_status

router = APIRouter(tags=["health"])


@router.get("/health")
def get_health_status() -> dict[str, str]:
    """Return health status for future HTTP adapters."""
    return build_health_status()
