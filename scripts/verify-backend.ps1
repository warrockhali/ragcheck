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

function Get-UsableUv {
    $command = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $command) {
        return $null
    }

    $versionOutput = & $command.Source --version
    if ($LASTEXITCODE -eq 0 -and $versionOutput -match "^uv ") {
        return $command.Source
    }

    return $null
}

function Get-UsablePython {
    $bundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
    $candidates = @("py", "python", "python3", $bundledPython)
    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if (-not $command) {
            continue
        }
        if ($command.Source -like "*\WindowsApps\python*") {
            continue
        }

        $versionOutput = & $command.Source --version
        if ($LASTEXITCODE -eq 0 -and $versionOutput -match "Python \d+\.\d+") {
            return $command.Source
        }
    }

    return $null
}

function Get-TestPython {
    param([string]$Python)

    $uv = Get-UsableUv
    $venvPython = Join-Root ".venv\Scripts\python.exe"
    if ($uv) {
        & $uv sync --extra dev --frozen | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "failed to sync backend verification dependencies with uv"
        }
        return $venvPython
    }

    if (-not (Test-Path -LiteralPath $venvPython -PathType Leaf)) {
        & $Python -m venv (Join-Root ".venv") | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "failed to create backend verification virtual environment"
        }
    }

    & $venvPython -m pip install --upgrade pip | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "failed to upgrade pip for backend verification"
    }

    & $venvPython -m pip install -e ".[dev]" | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "failed to install backend verification dependencies"
    }

    return $venvPython
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
    "backend\database.py",
    "backend\api\__init__.py",
    "backend\api\health.py",
    "backend\api\projects.py",
    "backend\services\__init__.py",
    "backend\services\health.py",
    "backend\services\projects.py",
    "backend\evaluators\__init__.py",
    "backend\clients\__init__.py",
    "backend\models\__init__.py",
    "backend\models\base.py",
    "backend\models\project.py",
    "backend\schemas\__init__.py",
    "backend\schemas\project.py",
    "backend\tests\README.md",
    "backend\tests\test_projects.py",
    "pyproject.toml",
    "uv.lock",
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
Assert-Contains "backend\app.py" "create_app"
Assert-Contains "backend\app.py" "FastAPI"
Assert-Contains "backend\app.py" "RAGCheck"
Assert-Contains "backend\api\health.py" "get_health_status"
Assert-Contains "backend\api\projects.py" "APIRouter"
Assert-Contains "backend\api\projects.py" "/projects"
Assert-Contains "backend\api\projects.py" "Project not found"
Assert-Contains "backend\services\health.py" "build_health_status"
Assert-Contains "backend\services\projects.py" "create_project"
Assert-Contains "backend\services\projects.py" "list_projects"
Assert-Contains "backend\services\projects.py" "get_project"
Assert-Contains "backend\services\projects.py" "update_project"
Assert-Contains "backend\services\projects.py" "delete_project"
Assert-Contains "backend\models\project.py" "__tablename__ = `"projects`""
Assert-Contains "backend\schemas\project.py" "ProjectCreate"
Assert-Contains "backend\schemas\project.py" "ProjectUpdate"
Assert-Contains "backend\schemas\project.py" "ProjectRead"
Assert-Contains "backend\tests\test_projects.py" "test_create_project"
Assert-Contains "backend\tests\test_projects.py" "test_unknown_project_returns_404"
Assert-Contains "backend\tests\test_projects.py" "test_update_unknown_project_returns_404"
Assert-Contains "backend\tests\test_projects.py" "test_delete_unknown_project_returns_404"
Assert-Contains "pyproject.toml" "fastapi"
Assert-Contains "pyproject.toml" "sqlalchemy"
Assert-Contains "pyproject.toml" "psycopg"
Assert-Contains "pyproject.toml" "pytest"
Assert-Contains "uv.lock" "version = 1"
Assert-Contains "uv.lock" "name = `"ragcheck`""
Assert-Contains "backend\README.md" "backend/app.py"
Assert-Contains "backend\README.md" "FastAPI"
Assert-Contains "Makefile" "verify-backend"
Assert-Contains "Makefile" "scripts/verify-backend.ps1"

foreach ($file in $requiredFiles + @("backend\README.md", "Makefile")) {
    Assert-NoTrailingWhitespace $file
}

$python = Get-UsablePython
if (-not $python) {
    throw "A usable Python runtime is required to run backend Project CRUD tests"
}

$testPython = Get-TestPython $python

& $testPython -m pytest backend\tests\test_projects.py

if ($LASTEXITCODE -ne 0) {
    throw "backend Project CRUD tests failed"
}

Write-Host "backend verification passed"
