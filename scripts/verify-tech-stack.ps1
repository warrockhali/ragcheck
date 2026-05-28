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

function Assert-NotContains {
    param(
        [string]$Path,
        [string]$Forbidden
    )
    $fullPath = Join-Root $Path
    $content = Get-Content -LiteralPath $fullPath -Raw
    if ($content.Contains($Forbidden)) {
        throw "Forbidden text found in ${Path}: $Forbidden"
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

$requiredFiles = @(
    "docs\tech-stack.md",
    "AGENTS.md",
    "db\README.md",
    "pyproject.toml",
    "uv.lock",
    "Makefile",
    "scripts\verify-tech-stack.ps1"
)

foreach ($file in $requiredFiles) {
    Assert-File $file
}

Assert-Contains "docs\tech-stack.md" "RAGCheck is a test harness for evaluating external RAG APIs."
Assert-Contains "docs\tech-stack.md" "Python 3.12+"
Assert-Contains "docs\tech-stack.md" "FastAPI"
Assert-Contains "docs\tech-stack.md" "Pydantic"
Assert-Contains "docs\tech-stack.md" "SQLAlchemy 2.x"
Assert-Contains "docs\tech-stack.md" "Alembic"
Assert-Contains "docs\tech-stack.md" "pytest"
Assert-Contains "docs\tech-stack.md" "uv"
Assert-Contains "docs\tech-stack.md" "ruff"
Assert-Contains "docs\tech-stack.md" "Vite"
Assert-Contains "docs\tech-stack.md" "React"
Assert-Contains "docs\tech-stack.md" "TypeScript"
Assert-Contains "docs\tech-stack.md" "Vitest"
Assert-Contains "docs\tech-stack.md" "PostgreSQL"
Assert-Contains "docs\tech-stack.md" "explicit user approval"
Assert-Contains "docs\tech-stack.md" "transitional artifacts"

Assert-Contains "AGENTS.md" "Technology Stack Rules"
Assert-Contains "AGENTS.md" "Backend: Python 3.12+, FastAPI, Pydantic, SQLAlchemy 2.x, Alembic, pytest, uv, ruff"
Assert-Contains "AGENTS.md" "Frontend: Node.js tooling, Vite, React, TypeScript, Vitest"
Assert-Contains "AGENTS.md" "Database: PostgreSQL"
Assert-Contains "AGENTS.md" "Do not change the technology stack without explicit user approval."
Assert-Contains "AGENTS.md" "SQLite is not the official MVP database."
Assert-Contains "AGENTS.md" "external RAG API evaluation harness"

Assert-Contains "db\README.md" "PostgreSQL is the official MVP database."
Assert-Contains "db\README.md" "transitional artifact"
Assert-Contains "db\README.md" "current transitional SQLite verification"
Assert-NotContains "db\README.md" "MVP SQLite schema"

Assert-Contains "pyproject.toml" "fastapi"
Assert-Contains "pyproject.toml" "pydantic"
Assert-Contains "pyproject.toml" "sqlalchemy"
Assert-Contains "pyproject.toml" "alembic"
Assert-Contains "pyproject.toml" "psycopg"
Assert-Contains "pyproject.toml" "pytest"
Assert-Contains "pyproject.toml" "ruff"
Assert-Contains "uv.lock" "name = `"ragcheck`""

Assert-Contains "Makefile" "verify-tech-stack"
Assert-Contains "Makefile" "scripts/verify-tech-stack.ps1"
Assert-Contains "Makefile" "verify-all: verify-agent-harness verify-repository-structure verify-backend verify-frontend verify-db verify-tech-stack"

foreach ($file in $requiredFiles) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "tech stack verification passed"
