# RAGCheck Agent Harness

RAGCheck uses a three-agent harness to keep planning, implementation, and evaluation separate.

Do not build a chatbot. Do not build an internal RAG document upload app as the MVP. The harness exists to ship a test harness for evaluating external RAG APIs.

## Planning Agent

The planning agent defines what to build, not how to build it.

Inputs:

- Current project instructions
- Current repository state
- User-requested milestone or product goal

Outputs:

- Milestone scope
- Out-of-scope items
- User-facing behavior
- Acceptance criteria
- Required entities, fields, metrics, and failure_type expectations
- Verification command to run after implementation

Rules:

- Choose one MVP milestone at a time.
- Describe product behavior and contracts, not code structure beyond established architecture rules.
- Preserve RAGCheck identity: external RAG API evaluation, not chat, not internal RAG generation.
- Communicate user-facing results in Korean.

## Development Agent

The development agent implements only the approved milestone.

Inputs:

- Approved planning output
- Repository instructions
- Current repository state

Outputs:

- Small, reviewable code or documentation changes
- Relevant automated tests or verification checks
- Verification results
- Concise implementation summary

Rules:

- Inspect the repository before coding.
- Do not expand scope beyond the approved milestone.
- Keep HTTP handling, services, evaluators, clients, models, and schemas separated.
- Preserve raw request and raw response when evaluating APIs where possible.
- Every evaluation result must include retrieval_score, groundedness_score, answer_score, and failure_type.
- Communicate user-facing results in Korean.

## Evaluation Agent

The evaluation agent uses the result as a tester and reports failures clearly.

Inputs:

- Planning acceptance criteria
- Development output
- Running app, scripts, or generated artifacts

Outputs:

- Pass/fail evaluation against acceptance criteria
- Reproduction steps for each failure
- Evidence from UI, API, logs, or command output
- Classification of product failures where applicable

Rules:

- Use the product like an external tester.
- Prefer real workflows over implementation inspection.
- Do not hide failures.
- Check for missing scores, missing failure_type, incorrect failure classification, and missing raw request/response preservation.
- Communicate user-facing results in Korean.

## Handoff Contract

Each agent handoff should include:

- Objective
- Scope and out-of-scope items
- Files changed or expected to change
- Verification command and result
- Known failures or risks
- Recommended next milestone

## Git Workflow

Create a task branch before implementation.

Keep commits small and grouped by reviewable intent.

Open PRs as draft by default.

Rules:

- Do not work directly on main unless the user explicitly asks.
- Use the codex/ prefix for task branches.
- Do not mix unrelated milestones in one commit.
- Stage only files that belong to the current milestone.
- Run the relevant verification command before each commit when practical.
- Write PR titles, PR descriptions, issues, and review comments in Korean.
