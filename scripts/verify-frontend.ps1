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
    "frontend\index.html",
    "frontend\src\app.js",
    "frontend\src\styles.css",
    "frontend\README.md",
    "scripts\verify-frontend.ps1"
)

foreach ($file in $requiredFiles) {
    Assert-File $file
}

Assert-Contains "frontend\index.html" "lang=""ko"""
Assert-Contains "frontend\index.html" "RAGCheck"
Assert-Contains "frontend\index.html" "Project"
Assert-Contains "frontend\index.html" "RagEndpoint"
Assert-Contains "frontend\index.html" "TestCase"
Assert-Contains "frontend\index.html" "EvaluationRun"
Assert-Contains "frontend\index.html" "EvaluationResult"
Assert-Contains "frontend\index.html" "retrieval_score"
Assert-Contains "frontend\index.html" "groundedness_score"
Assert-Contains "frontend\index.html" "answer_score"
Assert-Contains "frontend\index.html" "failure_type"
Assert-Contains "frontend\index.html" "latency_ms"
Assert-Contains "frontend\index.html" "not-implemented"
Assert-Contains "frontend\src\app.js" "Projects"
Assert-Contains "frontend\src\app.js" "RAG Endpoints"
Assert-Contains "frontend\src\app.js" "Test Cases"
Assert-Contains "frontend\src\app.js" "Evaluation Runs"
Assert-Contains "frontend\src\app.js" "Results"
Assert-Contains "Makefile" "verify-frontend"
Assert-Contains "Makefile" "scripts/verify-frontend.ps1"

$uiFiles = @(
    "frontend\index.html",
    "frontend\src\app.js",
    "frontend\src\styles.css"
)

$forbiddenTexts = @(
    "chatbot",
    "chat input",
    "assistant message",
    "document upload"
)

foreach ($file in $uiFiles) {
    foreach ($text in $forbiddenTexts) {
        Assert-NotContains $file $text
    }
}

$filesToCheck = $requiredFiles + @("Makefile")

foreach ($file in $filesToCheck) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "frontend verification passed"
