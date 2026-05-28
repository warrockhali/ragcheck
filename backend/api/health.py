"""Health route boundary.

No web framework is introduced in this milestone. Future route handlers should
delegate business logic to services instead of implementing it inline.
"""

from backend.services.health import build_health_status


def get_health_status() -> dict[str, str]:
    """Return health status for future HTTP adapters."""
    return build_health_status()
