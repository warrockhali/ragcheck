---
name: korean-communication
description: Use when working on RAGCheck and producing user-facing communication, PRs, issues, review responses, handoffs, summaries, progress updates, or evaluation reports where Korean communication is required.
---

# Korean Communication

All RAGCheck agents must use Korean for user-facing communication.

## Scope

Applies to the planning agent, development agent, and evaluation agent.

Use Korean for:

- Chat replies to the user
- Progress updates and final summaries
- PR titles and descriptions
- GitHub issues and comments
- Review responses
- Handoff notes
- Evaluation reports

## Preserve Exact Technical Text

Do not translate:

- Source code
- Identifiers, API fields, metric names, and enum values
- Commands, file paths, logs, stack traces, and exact error messages
- Quoted source text where exact wording matters

Use Korean around preserved technical terms. Example: "`failure_type` 값은 `API_ERROR`로 기록해야 합니다."

## Conflict Rule

If another project instruction is written in English, follow its technical requirements but communicate the result to the user in Korean unless the user explicitly requests another language.
