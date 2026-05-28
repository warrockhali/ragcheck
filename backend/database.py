"""Database session wiring for the FastAPI backend."""

from collections.abc import Iterator
from os import getenv

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker


DATABASE_URL = getenv(
    "DATABASE_URL",
    "postgresql+psycopg://postgres:postgres@localhost:5432/ragcheck",
)

_engine: Engine | None = None
_sessionmaker: sessionmaker[Session] | None = None


def get_engine() -> Engine:
    """Return the configured PostgreSQL engine."""
    global _engine
    if _engine is None:
        _engine = create_engine(DATABASE_URL, pool_pre_ping=True)
    return _engine


def get_sessionmaker() -> sessionmaker[Session]:
    """Return the configured session factory."""
    global _sessionmaker
    if _sessionmaker is None:
        _sessionmaker = sessionmaker(
            bind=get_engine(),
            autoflush=False,
            expire_on_commit=False,
        )
    return _sessionmaker


def get_db_session() -> Iterator[Session]:
    """Yield a SQLAlchemy session for request-scoped dependencies."""
    with get_sessionmaker() as session:
        yield session
