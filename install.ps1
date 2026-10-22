param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("codex", "pi", "opencode")]
    [string]$Agent
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSource = Join-Path $RepoRoot "skills"
$WorkflowsSource = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "workflows"))
$AgentsSource = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "AGENTS.md"))

if (-not (Test-Path -LiteralPath $SkillsSource -PathType Container)) {
    throw "Skills directory not found: $SkillsSource"
}
if (-not (Test-Path -LiteralPath $WorkflowsSource -PathType Container)) {
    throw "Workflows directory not found: $WorkflowsSource"
}
if (-not (Test-Path -LiteralPath $AgentsSource -PathType Leaf)) {
    throw "AGENTS.md not found: $AgentsSource"
}

switch ($Agent) {
    "codex" {
        $AgentRoot = Join-Path $HOME ".codex"
    }
    "pi" {
        $AgentRoot = Join-Path $HOME ".pi\agent"
    }
    "opencode" {
        $AgentRoot = Join-Path $HOME ".config\opencode"
    }
}

$SkillsRoot = Join-Path $AgentRoot "skills"
$WorkflowsRoot = Join-Path $AgentRoot "workflows"
$AgentsPath = Join-Path $AgentRoot "AGENTS.md"

foreach ($target in @($SkillsRoot, $WorkflowsRoot, $AgentsPath)) {
    if ($null -ne (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue)) {
        throw "Target already exists: $target"
    }
}

New-Item -ItemType Directory -Force -Path $AgentRoot | Out-Null

try {
    New-Item -ItemType Junction -Path $SkillsRoot -Target $SkillsSource | Out-Null
    New-Item -ItemType Junction -Path $WorkflowsRoot -Target $WorkflowsSource | Out-Null
    New-Item -ItemType SymbolicLink -Path $AgentsPath -Target $AgentsSource | Out-Null
} catch {
    foreach ($target in @($AgentsPath, $WorkflowsRoot, $SkillsRoot)) {
        if ($null -ne (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue)) {
            Remove-Item -LiteralPath $target -Force
        }
    }
    throw
}

Write-Host "[link] $Agent skills -> $SkillsSource"
Write-Host "[link] $Agent workflows -> $WorkflowsSource"
Write-Host "[link] $Agent AGENTS.md -> $AgentsSource"
