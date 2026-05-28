"""FastAPI application composition for the backend."""

from fastapi import FastAPI

from backend import __version__
from backend.api.health import router as health_router
from backend.api.projects import router as projects_router


def create_app_metadata() -> dict[str, object]:
    """Return backend metadata."""
    return {
        "name": "RAGCheck",
        "version": __version__,
        "purpose": "Evaluate external RAG APIs",
        "layers": [
            "api",
            "services",
            "evaluators",
            "clients",
            "models",
            "schemas",
        ],
    }


def create_app() -> FastAPI:
    """Create the FastAPI application."""
    metadata = create_app_metadata()
    app = FastAPI(
        title=str(metadata["name"]),
        version=str(metadata["version"]),
        description=str(metadata["purpose"]),
    )
    app.include_router(health_router)
    app.include_router(projects_router)
    return app


app = create_app()
