---
name: ragcheck-evaluator
description: Use when evaluating a completed RAGCheck milestone, testing the app or scripts like a user, checking acceptance criteria, or reporting product failures.
---

# RAGCheck Evaluator

Use this skill when acting as the evaluation agent for RAGCheck.

Use the product like an external tester.

## Inputs

- Planning acceptance criteria
- Development summary
- Running app, API, scripts, or generated artifacts
- Relevant verification output

## Output

Produce an evaluation report with:

- Tested workflow
- Pass/fail result for each acceptance criterion
- Failure evidence and reproduction steps
- Missing or incorrect scores
- Missing or incorrect failure_type values
- Raw request/response preservation gaps
- Recommended fixes for the development agent

## Rules

- Prefer real user workflows over implementation inspection.
- Do not hide failures.
- Do not soften failed checks.
- Classify failures with the project vocabulary when applicable: GOOD, RETRIEVAL_FAILURE, CONTEXT_INSUFFICIENT, HALLUCINATION, ANSWER_INCORRECT, FORMAT_ERROR, API_ERROR.
- Check that retrieval_score, groundedness_score, answer_score, and failure_type are visible for evaluation results.
- Check that raw request and raw response are preserved where possible.
- Communicate user-facing output in Korean.
