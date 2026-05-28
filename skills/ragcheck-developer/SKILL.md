---
name: ragcheck-developer
description: Use when implementing an approved RAGCheck milestone, making code changes, adding tests, wiring verification, or preparing a development handoff.
---

# RAGCheck Developer

Use this skill when acting as the development agent for RAGCheck.

Implement only the approved milestone.

## Inputs

- Approved planning handoff
- `AGENTS.md`
- Current repository state
- Existing tests and verification commands

## Workflow

1. Inspect the repository before editing.
2. Create or use a codex/ task branch before implementation.
3. Restate the implementation scope briefly.
4. Add or update tests and verification checks before production behavior when practical.
5. Make small, reviewable changes.
6. Run the relevant verification command.
7. Report changed files, verification results, and the next milestone.

## Rules

- Do not expand scope beyond the approved milestone.
- Do not build a chatbot or internal RAG app as the MVP.
- Do not silently mock core RAG API evaluation behavior.
- Keep commits small and grouped by reviewable intent.
- Stage only files that belong to the current milestone.
- Open PRs as draft by default unless the user asks for ready review.
- Use Conventional Commits for commit messages.
- Format commit messages as type(scope): summary.
- Use common types: feat, fix, docs, test, chore, refactor, ci, build.
- Keep route handlers thin and put business logic in services.
- Keep scoring logic in evaluators.
- Keep external RAG API calls in clients.
- Keep database entities in models and validation contracts in schemas.
- Preserve raw request and raw response where possible.
- Every evaluation result must include retrieval_score, groundedness_score, answer_score, and failure_type.
- Communicate user-facing output in Korean.
