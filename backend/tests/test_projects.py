from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from backend.app import create_app
from backend.database import get_db_session
from backend.models.base import Base


@pytest.fixture()
def client() -> Iterator[TestClient]:
    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)
    Base.metadata.create_all(bind=engine)
    app = create_app()

    def override_db_session() -> Iterator[Session]:
        with SessionLocal() as session:
            yield session

    app.dependency_overrides[get_db_session] = override_db_session
    try:
        yield TestClient(app)
    finally:
        app.dependency_overrides.clear()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


def test_create_project(client: TestClient) -> None:
    response = client.post(
        "/projects",
        json={"name": "Knowledge API", "description": "External RAG API checks"},
    )

    assert response.status_code == 201
    body = response.json()
    assert body["id"] == 1
    assert body["name"] == "Knowledge API"
    assert body["description"] == "External RAG API checks"
    assert body["created_at"]
    assert body["updated_at"]


def test_list_projects(client: TestClient) -> None:
    client.post("/projects", json={"name": "First"})
    client.post("/projects", json={"name": "Second", "description": "Next target"})

    response = client.get("/projects")

    assert response.status_code == 200
    assert [project["name"] for project in response.json()] == ["First", "Second"]


def test_get_project(client: TestClient) -> None:
    created = client.post("/projects", json={"name": "Debug Harness"}).json()

    response = client.get(f"/projects/{created['id']}")

    assert response.status_code == 200
    assert response.json()["name"] == "Debug Harness"


def test_update_project(client: TestClient) -> None:
    created = client.post("/projects", json={"name": "Before"}).json()

    response = client.patch(
        f"/projects/{created['id']}",
        json={"name": "After", "description": "Narrowed scope"},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "After"
    assert body["description"] == "Narrowed scope"


def test_delete_project(client: TestClient) -> None:
    created = client.post("/projects", json={"name": "Temporary"}).json()

    delete_response = client.delete(f"/projects/{created['id']}")
    get_response = client.get(f"/projects/{created['id']}")

    assert delete_response.status_code == 204
    assert get_response.status_code == 404


def test_unknown_project_returns_404(client: TestClient) -> None:
    response = client.get("/projects/999")

    assert response.status_code == 404
    assert response.json() == {"detail": "Project not found"}


def test_update_unknown_project_returns_404(client: TestClient) -> None:
    response = client.patch("/projects/999", json={"name": "Missing"})

    assert response.status_code == 404
    assert response.json() == {"detail": "Project not found"}


def test_delete_unknown_project_returns_404(client: TestClient) -> None:
    response = client.delete("/projects/999")

    assert response.status_code == 404
    assert response.json() == {"detail": "Project not found"}
