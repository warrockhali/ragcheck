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
    $content = $content.Replace("\_", "_").Replace("\#", "#").Replace("\-", "-").Replace("\.", ".")
    if (-not $content.Contains($Expected)) {
        throw "Missing expected text in ${Path}: $Expected"
    }
}

function Assert-SkillFrontmatter {
    param(
        [string]$Path,
        [string]$ExpectedName
    )
    $fullPath = Join-Root $Path
    $content = Get-Content -LiteralPath $fullPath -Raw
    if ($content -notmatch "(?s)^---\r?\n(?<frontmatter>.*?)\r?\n---\r?\n") {
        throw "Missing YAML frontmatter: $Path"
    }

    $frontmatter = $Matches["frontmatter"]
    if ($frontmatter -notmatch "(?m)^name:\s*$([regex]::Escape($ExpectedName))\s*$") {
        throw "Missing expected skill name '$ExpectedName' in $Path"
    }
    if ($frontmatter -notmatch "(?m)^description:\s*.+$") {
        throw "Missing skill description in $Path"
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
    "AGENTS.md",
    "Makefile",
    "docs\agent-harness.md",
    "skills\korean-communication\SKILL.md",
    "skills\ragcheck-planner\SKILL.md",
    "skills\ragcheck-developer\SKILL.md",
    "skills\ragcheck-evaluator\SKILL.md"
)

foreach ($file in $requiredFiles) {
    Assert-File $file
}

$agentInstructionChecks = @(
    "RAGCheck is not a chatbot.",
    "RAGCheck is a test harness for evaluating external RAG APIs.",
    "Every evaluation result must include scores and failure_type.",
    "Every API evaluation must preserve the raw request and raw response when possible.",
    "retrieval_score",
    "groundedness_score",
    "answer_score",
    "GOOD",
    "RETRIEVAL_FAILURE",
    "CONTEXT_INSUFFICIENT",
    "HALLUCINATION",
    "ANSWER_INCORRECT",
    "FORMAT_ERROR",
    "API_ERROR",
    "Communication Language",
    "Use Korean for all user-facing communication.",
    "Git Workflow",
    "Do not work directly on main unless the user explicitly asks.",
    "Create a task branch before implementation, using the codex/ prefix.",
    "Keep commits small and grouped by reviewable intent.",
    "Stage only files that belong to the current milestone.",
    "Run the relevant verification command before each commit when practical.",
    "PRs should be draft by default unless the user asks for ready review.",
    "PR titles, PR descriptions, issues, and review comments must be written in Korean.",
    "Use Conventional Commits for commit messages.",
    "Format commit messages as type(scope): Korean summary.",
    "Write commit summaries in Korean so squash merge commit bodies and GitHub commit lists stay Korean.",
    "Use common types: feat, fix, docs, test, chore, refactor, ci, build."
)

foreach ($expected in $agentInstructionChecks) {
    Assert-Contains "AGENTS.md" $expected
}

$harnessChecks = @(
    "Planning Agent",
    "Development Agent",
    "Evaluation Agent",
    "The planning agent defines what to build, not how to build it.",
    "The development agent implements only the approved milestone.",
    "The evaluation agent uses the result as a tester and reports failures clearly.",
    "Do not build a chatbot.",
    "failure_type",
    "Create a task branch before implementation.",
    "Keep commits small and grouped by reviewable intent.",
    "Open PRs as draft by default.",
    "Use Conventional Commits for commit messages."
)

foreach ($expected in $harnessChecks) {
    Assert-Contains "docs\agent-harness.md" $expected
}

Assert-SkillFrontmatter "skills\korean-communication\SKILL.md" "korean-communication"
Assert-SkillFrontmatter "skills\ragcheck-planner\SKILL.md" "ragcheck-planner"
Assert-SkillFrontmatter "skills\ragcheck-developer\SKILL.md" "ragcheck-developer"
Assert-SkillFrontmatter "skills\ragcheck-evaluator\SKILL.md" "ragcheck-evaluator"

Assert-Contains "skills\ragcheck-planner\SKILL.md" "Define what to build, not how to build it."
Assert-Contains "skills\ragcheck-developer\SKILL.md" "Implement only the approved milestone."
Assert-Contains "skills\ragcheck-developer\SKILL.md" "Create or use a codex/ task branch before implementation."
Assert-Contains "skills\ragcheck-developer\SKILL.md" "Keep commits small and grouped by reviewable intent."
Assert-Contains "skills\ragcheck-developer\SKILL.md" "Use Conventional Commits for commit messages."
Assert-Contains "skills\ragcheck-evaluator\SKILL.md" "Use the product like an external tester."
Assert-Contains "skills\korean-communication\SKILL.md" "All RAGCheck agents must use Korean for user-facing communication."

$filesToLint = $requiredFiles + @("scripts\verify-agent-harness.ps1")
foreach ($file in $filesToLint) {
    Assert-NoTrailingWhitespace $file
}

Write-Host "agent harness verification passed"
