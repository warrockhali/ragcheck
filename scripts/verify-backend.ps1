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
    "backend\api",
    "backend\services",
    "backend\evaluators",
    "backend\clients",
    "backend\models",
    "backend\schemas",
    "backend\tests"
)

$requiredFiles = @(
    "backend\__init__.py",
    "backend\app.py",
    "backend\api\__init__.py",
    "backend\api\health.py",
    "backend\services\__init__.py",
    "backend\services\health.py",
    "backend\evaluators\__init__.py",
    "backend\clients\__init__.py",
    "backend\models\__init__.py",
    "backend\schemas\__init__.py",
    "backend\tests\README.md",
    "scripts\verify-backend.ps1"
)

foreach ($directory in $requiredDirectories) {
    Assert-Directory $directory
}

foreach ($file in $requiredFiles) {
    Assert-File $file
}

Assert-Contains "backend\__init__.py" "__version__"
Assert-Contains "backend\app.py" "create_app_metadata"
Assert-Contains "backend\app.py" "RAGCheck"
Assert-Contains "backend\api\health.py" "get_health_status"
Assert-Contains "backend\services\health.py" "build_health_status"
Assert-Contains "backend\README.md" "backend/app.py"
Assert-Contains "backend\README.md" "No web framework is introduced in this milestone."
Assert-Contains "Makefile" "verify-backend"
Assert-Contains "Makefile" "scripts/verify-backend.ps1"

foreach ($file in $requiredFiles + @("backend\README.md", "Makefile")) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "backend verification passed"
