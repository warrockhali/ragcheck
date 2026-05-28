# Alembic Migrations

PostgreSQL is the official MVP database for RAGCheck.

The migration files in `versions/` are Alembic migrations for the official
PostgreSQL schema. The older `db/migrations/001_initial_schema.sql` file remains
a transitional SQLite artifact from before the PostgreSQL transition.
