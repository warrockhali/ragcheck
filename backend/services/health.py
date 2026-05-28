"""Health service for backend skeleton verification."""


def build_health_status() -> dict[str, str]:
    """Return a minimal health payload."""
    return {"status": "ok", "service": "backend"}
