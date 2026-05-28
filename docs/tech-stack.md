# Tech Stack

RAGCheck is a test harness for evaluating external RAG APIs. It is not a
chatbot, a RAG app builder, or a document upload app.

## Approved Stack

Backend:

- Python 3.12+
- FastAPI
- Pydantic
- SQLAlchemy 2.x
- Alembic
- pytest
- uv
- ruff

Frontend:

- Node.js tooling
- Vite
- React
- TypeScript
- Vitest

Database:

- PostgreSQL

Verification:

- Makefile
- `scripts/verify-*.ps1`

## Change Control

The approved stack is part of the MVP product contract. Do not change the
technology stack without explicit user approval.

## Database Alignment

PostgreSQL is the official MVP database. Any remaining SQLite migration or
verification files are transitional artifacts from the pre-PostgreSQL phase.
They should not be described as the official MVP database contract.

This milestone does not require running a PostgreSQL server, adding Docker
Compose, configuring CI services, regenerating Alembic migrations, or deleting
the transitional SQLite migration.
