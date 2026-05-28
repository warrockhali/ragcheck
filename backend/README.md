# Backend

Backend code will evaluate external RAG APIs. It must not implement chatbot behavior or internal document indexing as the MVP product.

Responsibilities:

- `backend/app.py`: FastAPI application composition entry point.
- `api/`: api routes for HTTP handling.
- `services/`: services for business logic and orchestration.
- `evaluators/`: evaluators for scoring retrieval_score, groundedness_score, answer_score, and failure_type.
- `clients/`: clients for calling external RAG APIs.
- `models/`: models for database entities.
- `schemas/`: schemas for request/response validation.
- `tests/`: backend tests and fixtures.

Evaluation behavior must preserve raw request and raw response where possible.

Project CRUD uses FastAPI routes, Pydantic schemas, SQLAlchemy 2.x models, and
service functions so route handlers do not contain database query logic.
