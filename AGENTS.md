\# RAGCheck Agent Instructions



\## Project Identity



RAGCheck is not a chatbot.

RAGCheck is not a RAG app builder.

RAGCheck is a test harness for evaluating external RAG APIs.



RAGCheck calls a user-provided RAG API endpoint with curated test cases, extracts the answer and retrieved contexts from the response, and evaluates retrieval quality, faithfulness, answer correctness, latency, and failure types.



\## Core Goal



Help developers test and debug existing RAG APIs.



RAGCheck should answer:



\- Did the RAG API return relevant retrieved contexts?

\- Is the generated answer grounded in those contexts?

\- Is the answer correct compared to the expected answer?

\- Did the failure come from retrieval, insufficient context, hallucination, or answer generation?

\- How slow or expensive was the response?



\## Harness Engineering Roles



RAGCheck development uses three cooperating agent roles.



\### Planning Agent



The planning agent defines what to build, not how to build it.



Responsibilities:



\- Select the next MVP milestone.

\- Define user-facing behavior, scope, out-of-scope items, acceptance criteria, and verification commands.

\- Avoid prescribing implementation details unless they are part of the product contract.



\### Development Agent



The development agent implements only the approved milestone.



Responsibilities:



\- Inspect the repository before editing.

\- Keep changes small and reviewable.

\- Keep route, service, evaluator, client, model, and schema responsibilities separated.

\- Run the relevant verification command after changes.



\### Evaluation Agent



The evaluation agent uses the result as a tester and reports failures clearly.



Responsibilities:



\- Exercise the implemented workflow from a user's perspective.

\- Report missing behavior, confusing output, incorrect scores, missing failure_type values, and raw request/response preservation gaps.

\- Do not hide failures or soften failed checks.



\## Absolute Rules



\- Do not build a chatbot.

\- Do not build a RAG document upload app as the main product.

\- Do not build a generic SaaS platform.

\- Do not implement authentication in the first MVP.

\- Do not implement payment, team, invitation, or organization features.

\- Do not hide failures. Show them clearly.

\- Every evaluation result must include scores and failure\_type.

\- Every API evaluation must preserve the raw request and raw response when possible.

\- Prefer simple, explainable evaluation logic over magical black-box logic.

\- Build MVP features before nice-to-have features.



\## MVP Scope



The first MVP focuses on evaluating external RAG APIs.



Must-have features:



1\. Project management

2\. RAG endpoint configuration

3\. Response mapping

4\. Test case management

5\. Evaluation run execution

6\. Evaluation result dashboard

7\. Failure type classification



Do not implement internal document indexing or internal RAG generation as the main feature in MVP.



\## Main Entities



\### Project



A workspace for evaluating one or more RAG APIs.



\### RagEndpoint



A user-configured external RAG API endpoint.



Required fields:



\- name

\- endpoint\_url

\- method

\- headers\_template

\- body\_template

\- response\_mapping

\- timeout\_ms



\### TestCase



A curated test item.



Required fields:



\- question

\- expected\_answer

\- expected\_context\_hint

\- category

\- difficulty



\### EvaluationRun



A batch test run against one RagEndpoint using selected TestCases.



\### EvaluationResult



The result of one TestCase execution.



Required fields:



\- request\_payload

\- response\_body

\- actual\_answer

\- actual\_contexts

\- status\_code

\- retrieval\_score

\- groundedness\_score

\- answer\_score

\- failure\_type

\- latency\_ms

\- error\_message



\## Evaluation Metrics



Use these metric names consistently:



\- retrieval\_score

\- groundedness\_score

\- answer\_score



These can later map to formal RAG evaluation metrics:



\- retrieval\_score: context precision / context recall / context relevancy

\- groundedness\_score: faithfulness

\- answer\_score: answer correctness / answer similarity



\## Failure Types



Use these failure types:



\- GOOD

\- RETRIEVAL\_FAILURE

\- CONTEXT\_INSUFFICIENT

\- HALLUCINATION

\- ANSWER\_INCORRECT

\- FORMAT\_ERROR

\- API\_ERROR



Initial classification rules:



\- If the endpoint call fails: API\_ERROR

\- If response mapping fails: FORMAT\_ERROR

\- If retrieval\_score < 0.3: RETRIEVAL\_FAILURE

\- If retrieval\_score >= 0.3 and groundedness\_score < 0.4: HALLUCINATION

\- If retrieval\_score >= 0.3 and answer\_score < 0.4: ANSWER\_INCORRECT

\- Otherwise: GOOD



\## Architecture Rules



Keep responsibilities separated.



Backend should use:



\- api routes for HTTP handling

\- services for business logic

\- evaluators for scoring

\- clients for calling external RAG APIs

\- models for database entities

\- schemas for request/response validation



Do not put evaluation logic directly inside route handlers.



\## Development Order



Build one milestone at a time.



Recommended order:



1\. Agent instructions, skills, and verification harness

2\. Repository structure

3\. Backend skeleton

4\. Frontend skeleton

5\. Database setup

6\. Project CRUD

7\. RagEndpoint CRUD

8\. TestCase CRUD

9\. External RAG API caller

10\. Response mapping

11\. Evaluation run execution

12\. Evaluation scoring

13\. Result dashboard

14\. Run comparison

15\. Demo scenario and README



\## Git Workflow



\- Do not work directly on main unless the user explicitly asks.

\- Create a task branch before implementation, using the codex/ prefix.

\- Keep commits small and grouped by reviewable intent.

\- Do not mix unrelated milestones in one commit.

\- Stage only files that belong to the current milestone.

\- Run the relevant verification command before each commit when practical.

\- PRs should be draft by default unless the user asks for ready review.

\- PR titles, PR descriptions, issues, and review comments must be written in Korean.

\- Use Conventional Commits for commit messages.

\- Format commit messages as type(scope): Korean summary.

\- Use common types: feat, fix, docs, test, chore, refactor, ci, build.

\- Write commit summaries in Korean so squash merge commit bodies and GitHub commit lists stay Korean.



\## Verification Rules



After code changes, run the relevant verification command.



\- Backend changes: make verify-backend

\- Frontend changes: make verify-frontend

\- DB changes: make verify-db

\- Large changes: make verify-all



If a command cannot be run, explain why.

If verification fails, report the failure clearly.



\## Communication Language



This applies to every RAGCheck agent, including the planning agent, development agent, and evaluation agent.



\- Use Korean for all user-facing communication.

\- This includes chat replies, progress updates, final summaries, PR titles, PR descriptions, GitHub issues, GitHub comments, review responses, handoff notes, and evaluation reports.

\- Do not translate source code, identifiers, API field names, commands, file paths, logs, stack traces, metric names, or exact error messages.

\- Technical documentation may keep established English terms when they are clearer, but the surrounding explanation should be Korean unless the user explicitly requests another language.

\- When summarizing English specs, skills, or repository instructions, answer in Korean and preserve exact English names only where precision matters.



\## Agent Behavior



Before coding:



\- Inspect the current file structure.

\- State the intended scope briefly.

\- Implement only the requested milestone.



During coding:



\- Make small, reviewable changes.

\- Do not rewrite unrelated files.

\- Do not add unnecessary dependencies.

\- Do not silently mock core features.



After coding:



\- Summarize changed files.

\- Summarize verification results.

\- Recommend the next milestone.
