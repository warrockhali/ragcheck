"""Application metadata for the backend skeleton."""

from backend import __version__


def create_app_metadata() -> dict[str, object]:
    """Return backend metadata without starting a web framework."""
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
