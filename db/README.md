# Database

Database files define persistence for RAGCheck database entities.

PostgreSQL is the official MVP database. Any remaining SQLite migration or
verification in this directory is a transitional artifact from before the
PostgreSQL transition.

MVP entities:

- Project
- RagEndpoint
- TestCase
- EvaluationRun
- EvaluationResult

Use `migrations/` for schema migrations and `seeds/` for demo or development seed data.

## PostgreSQL Alembic migrations

`alembic/versions/20260529_0001_create_projects.py` creates the official
PostgreSQL `projects` table for the Project CRUD milestone.

## Transitional SQLite schema

`migrations/001_initial_schema.sql` is the current transitional SQLite schema
artifact for:

- `projects`
- `rag_endpoints`
- `test_cases`
- `evaluation_runs`
- `evaluation_results`

The schema preserves `request_payload` and `response_body` on evaluation results
when the external RAG API call makes them available. It also constrains
`failure_type` to the MVP values:

- `GOOD`
- `RETRIEVAL_FAILURE`
- `CONTEXT_INSUFFICIENT`
- `HALLUCINATION`
- `ANSWER_INCORRECT`
- `FORMAT_ERROR`
- `API_ERROR`

Run `make verify-db` to apply the transitional migration to a temporary SQLite
database and check table, column, foreign key, and CHECK constraint contracts.
This is current transitional SQLite verification, not PostgreSQL runtime
verification.
