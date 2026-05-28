# RAGCheck

RAGCheck is a test harness for evaluating external RAG APIs.

The MVP helps developers configure an external RAG endpoint, run curated test cases, inspect retrieved contexts and answers, and evaluate retrieval quality, groundedness, answer correctness, latency, and failure_type.

## Repository Structure

- `backend/`: API routes, services, evaluators, clients, models, schemas, and backend tests.
- `frontend/`: frontend source code and tests for the evaluation workflow.
- `db/`: database migrations and seed data.
- `docs/`: project documentation.
- `scripts/`: verification and maintenance scripts.
- `skills/`: project-local agent skills.

See `docs/repository-structure.md` for ownership boundaries.

## Verification

Backend dependencies are declared in `pyproject.toml` and locked in `uv.lock`.
When `uv` is installed, backend verification syncs `.venv` from the lockfile.

Run all available checks:

```powershell
make verify-all
```

If `make` is unavailable on Windows, run the scripts directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-agent-harness.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-repository-structure.ps1
```
