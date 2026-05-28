"""Project CRUD service layer."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from backend.models.project import Project
from backend.schemas.project import ProjectCreate, ProjectUpdate


def create_project(session: Session, payload: ProjectCreate) -> Project:
    """Create and persist a project."""
    project = Project(name=payload.name, description=payload.description)
    session.add(project)
    session.commit()
    session.refresh(project)
    return project


def list_projects(session: Session) -> list[Project]:
    """Return projects in creation order."""
    return list(session.scalars(select(Project).order_by(Project.id)).all())


def get_project(session: Session, project_id: int) -> Project | None:
    """Return one project by id, if it exists."""
    return session.get(Project, project_id)


def update_project(
    session: Session,
    project: Project,
    payload: ProjectUpdate,
) -> Project:
    """Apply a partial project update."""
    updates = payload.model_dump(exclude_unset=True)
    for field, value in updates.items():
        setattr(project, field, value)
    session.add(project)
    session.commit()
    session.refresh(project)
    return project


def delete_project(session: Session, project: Project) -> None:
    """Delete a project."""
    session.delete(project)
    session.commit()
