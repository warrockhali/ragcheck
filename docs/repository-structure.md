# Repository Structure

RAGCheck is not a chatbot. RAGCheck is a test harness for evaluating external RAG APIs.

This repository structure reserves clear ownership boundaries before backend, frontend, and database skeletons are implemented.

## Top-Level Layout

- `backend/`: backend application code.
- `frontend/`: frontend application code.
- `db/`: database migrations and seed data.
- `docs/`: project documentation.
- `scripts/`: verification and maintenance scripts.
- `skills/`: project-local agent skills.

## Backend Layout

- `backend/api`: HTTP route handling only.
- `backend/services`: business logic and orchestration.
- `backend/evaluators`: scoring and failure_type classification.
- `backend/clients`: external RAG API clients.
- `backend/models`: database entity definitions.
- `backend/schemas`: request and response validation contracts.
- `backend/tests`: backend tests and fixtures.

Route handlers should not contain evaluation logic. Evaluators should expose explainable scoring behavior for retrieval_score, groundedness_score, answer_score, and failure_type.

## Frontend Layout

- `frontend/src`: frontend source code.
- `frontend/tests`: frontend tests.

The frontend should show failures clearly and prioritize the evaluation workflow over generic SaaS or chatbot surfaces.

## Database Layout

- `db/migrations`: schema migrations.
- `db/seeds`: demo and development seed data.

Database work should preserve the main entities defined in `AGENTS.md`: Project, RagEndpoint, TestCase, EvaluationRun, and EvaluationResult.
