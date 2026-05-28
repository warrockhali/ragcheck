# Database

Database files define persistence for RAGCheck database entities.

MVP entities:

- Project
- RagEndpoint
- TestCase
- EvaluationRun
- EvaluationResult

Use `migrations/` for schema migrations and `seeds/` for demo or development seed data.

## Initial schema

`migrations/001_initial_schema.sql` creates the MVP SQLite schema for:

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

Run `make verify-db` to apply the migration to a temporary SQLite database and
check table, column, foreign key, and CHECK constraint contracts.
