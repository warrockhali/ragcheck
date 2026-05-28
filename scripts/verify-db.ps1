$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Join-Root {
    param([string]$Path)
    return Join-Path $Root $Path
}

function Assert-File {
    param([string]$Path)
    $fullPath = Join-Root $Path
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        throw "Missing required file: $Path"
    }
}

function Assert-Contains {
    param(
        [string]$Path,
        [string]$Expected
    )
    $fullPath = Join-Root $Path
    $content = Get-Content -LiteralPath $fullPath -Raw
    if (-not $content.Contains($Expected)) {
        throw "Missing expected text in ${Path}: $Expected"
    }
}

function Assert-NoTrailingWhitespace {
    param([string]$Path)
    $fullPath = Join-Root $Path
    $lineNumber = 0
    Get-Content -LiteralPath $fullPath | ForEach-Object {
        $lineNumber += 1
        if ($_ -match "\s+$") {
            throw "Trailing whitespace in ${Path}:$lineNumber"
        }
    }
}

$migration = "db\migrations\001_initial_schema.sql"
$checkedFiles = @(
    $migration,
    "db\README.md",
    "Makefile"
)

Assert-File $migration
Assert-Contains "Makefile" "scripts/verify-db.ps1"
Assert-Contains "Makefile" "verify-all: verify-agent-harness verify-repository-structure verify-backend verify-frontend verify-db"
Assert-Contains "db\README.md" "001_initial_schema.sql"

$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    throw "Node.js is required for SQLite schema verification"
}

$verifyScript = @'
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { DatabaseSync } from "node:sqlite";

const root = process.argv[2];
const migration = join(root, "db", "migrations", "001_initial_schema.sql");
const db = new DatabaseSync(":memory:");

db.exec("PRAGMA foreign_keys = ON");
db.exec(readFileSync(migration, "utf8"));

const expectedColumns = {
  projects: ["id", "name", "description", "created_at", "updated_at"],
  rag_endpoints: [
    "id",
    "project_id",
    "name",
    "endpoint_url",
    "method",
    "headers_template",
    "body_template",
    "response_mapping",
    "timeout_ms",
    "created_at",
    "updated_at",
  ],
  test_cases: [
    "id",
    "project_id",
    "question",
    "expected_answer",
    "expected_context_hint",
    "category",
    "difficulty",
    "created_at",
    "updated_at",
  ],
  evaluation_runs: [
    "id",
    "project_id",
    "rag_endpoint_id",
    "name",
    "status",
    "started_at",
    "completed_at",
    "created_at",
    "updated_at",
  ],
  evaluation_results: [
    "id",
    "evaluation_run_id",
    "test_case_id",
    "request_payload",
    "response_body",
    "actual_answer",
    "actual_contexts",
    "status_code",
    "retrieval_score",
    "groundedness_score",
    "answer_score",
    "failure_type",
    "latency_ms",
    "error_message",
    "created_at",
  ],
};

function fail(message) {
  throw new Error(message);
}

for (const [table, columns] of Object.entries(expectedColumns)) {
  const actual = new Set(db.prepare(`PRAGMA table_info(${table})`).all().map((row) => row.name));
  const missing = columns.filter((column) => !actual.has(column));
  if (missing.length > 0) {
    fail(`${table} missing columns: ${missing.join(", ")}`);
  }
}

const foreignKeyExpectations = {
  rag_endpoints: ["projects"],
  test_cases: ["projects"],
  evaluation_runs: ["projects", "rag_endpoints"],
  evaluation_results: ["evaluation_runs", "test_cases"],
};

for (const [table, expectedTables] of Object.entries(foreignKeyExpectations)) {
  const actual = new Set(db.prepare(`PRAGMA foreign_key_list(${table})`).all().map((row) => row.table));
  const missing = expectedTables.filter((expectedTable) => !actual.has(expectedTable));
  if (missing.length > 0) {
    fail(`${table} missing foreign keys to: ${missing.join(", ")}`);
  }
}

const createSql = Object.fromEntries(
  db.prepare("SELECT name, sql FROM sqlite_master WHERE type = 'table'").all()
    .map((row) => [row.name, row.sql]),
);

for (const method of ["GET", "POST", "PUT", "PATCH", "DELETE"]) {
  if (!createSql.rag_endpoints.includes(`'${method}'`)) {
    fail(`rag_endpoints method CHECK missing ${method}`);
  }
}

for (const failureType of [
  "GOOD",
  "RETRIEVAL_FAILURE",
  "CONTEXT_INSUFFICIENT",
  "HALLUCINATION",
  "ANSWER_INCORRECT",
  "FORMAT_ERROR",
  "API_ERROR",
]) {
  if (!createSql.evaluation_results.includes(`'${failureType}'`)) {
    fail(`evaluation_results failure_type CHECK missing ${failureType}`);
  }
}

const projectId = db.prepare("INSERT INTO projects (name) VALUES (?) RETURNING id")
  .get("Demo Project").id;
const endpointId = db.prepare(`
  INSERT INTO rag_endpoints (
    project_id, name, endpoint_url, method, headers_template,
    body_template, response_mapping, timeout_ms
  )
  VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  RETURNING id
`).get(
  projectId,
  "Demo Endpoint",
  "https://example.com/rag",
  "POST",
  "{}",
  "{}",
  "{}",
  5000,
).id;
const testCaseId = db.prepare(`
  INSERT INTO test_cases (
    project_id, question, expected_answer, expected_context_hint,
    category, difficulty
  )
  VALUES (?, ?, ?, ?, ?, ?)
  RETURNING id
`).get(
  projectId,
  "What is RAGCheck?",
  "A RAG API test harness",
  "external RAG APIs",
  "smoke",
  "easy",
).id;
const runId = db.prepare(`
  INSERT INTO evaluation_runs (project_id, rag_endpoint_id, name, status)
  VALUES (?, ?, ?, ?)
  RETURNING id
`).get(projectId, endpointId, "Smoke run", "COMPLETED").id;

db.prepare(`
  INSERT INTO evaluation_results (
    evaluation_run_id, test_case_id, request_payload, response_body,
    actual_answer, actual_contexts, status_code, retrieval_score,
    groundedness_score, answer_score, failure_type, latency_ms,
    error_message
  )
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
`).run(
  runId,
  testCaseId,
  '{"question":"What is RAGCheck?"}',
  '{"answer":"A harness"}',
  "A harness",
  '["external RAG APIs"]',
  200,
  0.9,
  0.8,
  0.7,
  "GOOD",
  123,
  null,
);

function assertRejected(statement, params, message) {
  try {
    statement.run(...params);
  } catch {
    return;
  }
  fail(message);
}

assertRejected(
  db.prepare(`
    INSERT INTO evaluation_results (
      evaluation_run_id, test_case_id, failure_type
    )
    VALUES (?, ?, ?)
  `),
  [runId, testCaseId, "UNKNOWN"],
  "evaluation_results failure_type CHECK did not reject UNKNOWN",
);

assertRejected(
  db.prepare(`
    INSERT INTO rag_endpoints (
      project_id, name, endpoint_url, method, headers_template,
      body_template, response_mapping, timeout_ms
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `),
  [projectId, "Bad Endpoint", "https://example.com/rag", "TRACE", "{}", "{}", "{}", 5000],
  "rag_endpoints method CHECK did not reject TRACE",
);

assertRejected(
  db.prepare(`
    INSERT INTO evaluation_results (
      evaluation_run_id, test_case_id, retrieval_score, failure_type
    )
    VALUES (?, ?, ?, ?)
  `),
  [runId, testCaseId, 1.1, "GOOD"],
  "evaluation_results retrieval_score CHECK did not reject 1.1",
);

assertRejected(
  db.prepare(`
    INSERT INTO evaluation_results (
      evaluation_run_id, test_case_id, failure_type
    )
    VALUES (?, ?, ?)
  `),
  [999999, testCaseId, "GOOD"],
  "evaluation_results foreign key did not reject an unknown evaluation_run_id",
);

console.log("SQLite schema contract verification passed");
'@

$tempScript = [System.IO.Path]::GetTempFileName() + ".mjs"
Set-Content -LiteralPath $tempScript -Value $verifyScript -Encoding UTF8
try {
    & $node.Source $tempScript $Root
    if ($LASTEXITCODE -ne 0) {
        throw "SQLite schema contract verification failed"
    }
}
finally {
    Remove-Item -LiteralPath $tempScript -Force
}

foreach ($file in $checkedFiles) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "db verification passed"
