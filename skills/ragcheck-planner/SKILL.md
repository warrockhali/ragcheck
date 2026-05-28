---
name: ragcheck-planner
description: Use when planning a RAGCheck milestone, writing product scope, preparing issues or PRDs, defining acceptance criteria, or handing work to a development agent.
---

# RAGCheck Planner

Use this skill when acting as the planning agent for RAGCheck.

Define what to build, not how to build it.

## Inputs

- User request
- `AGENTS.md`
- Current repository state
- Existing RAGCheck milestone order

## Output

Produce a concise planning handoff with:

- Milestone objective
- In-scope behavior
- Out-of-scope behavior
- User-facing acceptance criteria
- Required data entities, metric names, and failure_type values
- Verification command the development agent must run

## Rules

- Plan one milestone at a time.
- Keep RAGCheck focused on evaluating external RAG APIs.
- Do not plan chatbot, internal RAG document indexing, auth, payment, team, invitation, or organization features for the MVP.
- Avoid implementation details unless they are part of an API contract, schema, metric, or required architecture boundary.
- Make failures visible in acceptance criteria.
- Require retrieval_score, groundedness_score, answer_score, and failure_type for every evaluation result.
- Require raw request and raw response preservation where possible.
- Communicate user-facing output in Korean.
