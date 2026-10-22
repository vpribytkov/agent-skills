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

$Targets = @(
    @{
        Name = "skills"
        Path = Join-Path $AgentRoot "skills"
        Source = $SkillsSource
        Type = "Junction"
    },
    @{
        Name = "workflows"
        Path = Join-Path $AgentRoot "workflows"
        Source = $WorkflowsSource
        Type = "Junction"
    },
    @{
        Name = "AGENTS.md"
        Path = Join-Path $AgentRoot "AGENTS.md"
        Source = $AgentsSource
        Type = "SymbolicLink"
    }
)

New-Item -ItemType Directory -Force -Path $AgentRoot | Out-Null

$Failed = $false

foreach ($entry in $Targets) {
    $existing = Get-Item -LiteralPath $entry.Path -Force -ErrorAction SilentlyContinue
    if ($null -ne $existing) {
        Write-Host "[skip] $Agent $($entry.Name) -> $($entry.Path) (already exists)"
        continue
    }

    try {
        New-Item -ItemType $entry.Type -Path $entry.Path -Target $entry.Source | Out-Null
        Write-Host "[link] $Agent $($entry.Name) -> $($entry.Source)"
    } catch {
        $Failed = $true
        Write-Host "[error] $Agent $($entry.Name) -> $($entry.Path): $($_.Exception.Message)"
    }
}

if ($Failed) {
    throw "Installation completed with one or more link errors."
}
