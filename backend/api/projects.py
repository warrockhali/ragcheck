"""Project HTTP routes."""

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.orm import Session

from backend.database import get_db_session
from backend.models.project import Project
from backend.schemas.project import ProjectCreate, ProjectRead, ProjectUpdate
from backend.services import projects as project_service


router = APIRouter(prefix="/projects", tags=["projects"])

DbSession = Annotated[Session, Depends(get_db_session)]


def _require_project(session: Session, project_id: int) -> Project:
    project = project_service.get_project(session, project_id)
    if project is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Project not found",
        )
    return project


@router.post("", response_model=ProjectRead, status_code=status.HTTP_201_CREATED)
def create_project(payload: ProjectCreate, session: DbSession) -> Project:
    """Create a Project."""
    return project_service.create_project(session, payload)


@router.get("", response_model=list[ProjectRead])
def list_projects(session: DbSession) -> list[Project]:
    """List Projects."""
    return project_service.list_projects(session)


@router.get("/{project_id}", response_model=ProjectRead)
def get_project(project_id: int, session: DbSession) -> Project:
    """Get one Project."""
    return _require_project(session, project_id)


@router.patch("/{project_id}", response_model=ProjectRead)
def update_project(
    project_id: int,
    payload: ProjectUpdate,
    session: DbSession,
) -> Project:
    """Update one Project."""
    project = _require_project(session, project_id)
    return project_service.update_project(session, project, payload)


@router.delete("/{project_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_project(project_id: int, session: DbSession) -> Response:
    """Delete one Project."""
    project = _require_project(session, project_id)
    project_service.delete_project(session, project)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
