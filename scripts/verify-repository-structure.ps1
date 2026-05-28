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

function Assert-Directory {
    param([string]$Path)
    $fullPath = Join-Root $Path
    if (-not (Test-Path -LiteralPath $fullPath -PathType Container)) {
        throw "Missing required directory: $Path"
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

$requiredDirectories = @(
    "backend",
    "backend\api",
    "backend\services",
    "backend\evaluators",
    "backend\clients",
    "backend\models",
    "backend\schemas",
    "backend\tests",
    "frontend",
    "frontend\src",
    "frontend\tests",
    "db",
    "db\migrations",
    "db\seeds",
    "docs"
)

$requiredFiles = @(
    "README.md",
    "Makefile",
    "backend\README.md",
    "frontend\README.md",
    "db\README.md",
    "docs\repository-structure.md",
    "scripts\verify-repository-structure.ps1"
)

foreach ($directory in $requiredDirectories) {
    Assert-Directory $directory
}

foreach ($file in $requiredFiles) {
    Assert-File $file
}

Assert-Contains "README.md" "RAGCheck is a test harness for evaluating external RAG APIs."
Assert-Contains "README.md" "make verify-all"
Assert-Contains "docs\repository-structure.md" "RAGCheck is not a chatbot."
Assert-Contains "docs\repository-structure.md" "backend/api"
Assert-Contains "docs\repository-structure.md" "backend/services"
Assert-Contains "docs\repository-structure.md" "backend/evaluators"
Assert-Contains "docs\repository-structure.md" "backend/clients"
Assert-Contains "docs\repository-structure.md" "backend/models"
Assert-Contains "docs\repository-structure.md" "backend/schemas"
Assert-Contains "docs\repository-structure.md" "frontend/src"
Assert-Contains "docs\repository-structure.md" "db/migrations"
Assert-Contains "Makefile" "verify-repository-structure"
Assert-Contains "Makefile" "scripts/verify-repository-structure.ps1"
Assert-Contains "backend\README.md" "api routes for HTTP handling"
Assert-Contains "backend\README.md" "services for business logic"
Assert-Contains "backend\README.md" "evaluators for scoring"
Assert-Contains "backend\README.md" "clients for calling external RAG APIs"
Assert-Contains "backend\README.md" "models for database entities"
Assert-Contains "backend\README.md" "schemas for request/response validation"
Assert-Contains "frontend\README.md" "Evaluation result dashboard"
Assert-Contains "db\README.md" "database entities"

foreach ($file in $requiredFiles) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "repository structure verification passed"
