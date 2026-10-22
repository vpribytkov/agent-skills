param(
    [string]$TargetRoot = (Join-Path $HOME ".agents\skills"),
    [switch]$InstallAgents,
    [string]$WorkflowsRoot = (Join-Path $HOME ".agents\workflows"),
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" })
)

$ErrorActionPreference = "Stop"
if (-not $InstallAgents -and ($PSBoundParameters.ContainsKey("WorkflowsRoot") -or $PSBoundParameters.ContainsKey("CodexHome"))) {
    throw "AGENTS options require -InstallAgents."
}

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceRoot = Join-Path $RepoRoot "skills"

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
    throw "Skills directory not found: $SourceRoot"
}

$TargetRoot = [System.IO.Path]::GetFullPath($TargetRoot)
New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

Get-ChildItem -LiteralPath $SourceRoot -Directory | ForEach-Object {
    $exampleProfile = Join-Path $_.FullName "profile.example.yaml"
    $localProfile = Join-Path $_.FullName "profile.yaml"
    if ((Test-Path -LiteralPath $exampleProfile -PathType Leaf) -and -not (Test-Path -LiteralPath $localProfile)) {
        Copy-Item -LiteralPath $exampleProfile -Destination $localProfile
        Write-Host "[init] $($_.Name) profile.yaml from profile.example.yaml"
    }
}

$created = 0
$existing = 0
$collisions = 0

Get-ChildItem -LiteralPath $SourceRoot -Directory | Sort-Object Name | ForEach-Object {
    $source = [System.IO.Path]::GetFullPath($_.FullName)
    $target = Join-Path $TargetRoot $_.Name

    $current = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($null -ne $current) {
        $currentTarget = $null
        if ($current.PSObject.Properties.Name -contains "Target" -and $current.Target) {
            $rawTarget = @($current.Target)[0]
            try {
                $currentTarget = [System.IO.Path]::GetFullPath($rawTarget)
            } catch {
                $currentTarget = $rawTarget
            }
        }

        if ($current.LinkType -in @("Junction", "SymbolicLink") -and $currentTarget -eq $source) {
            Write-Host "[ok]   $($_.Name) -> $source"
            $existing++
            return
        }

        Write-Warning "[skip] $($_.Name): target already exists and is not the expected link: $target"
        $collisions++
        return
    }

    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Write-Host "[link] $($_.Name) -> $source"
    $created++
}

Write-Host ""
Write-Host "Installed skill links in: $TargetRoot"
Write-Host "Created: $created; already correct: $existing; collisions: $collisions"

if ($collisions -gt 0) {
    exit 2
}

if ($InstallAgents) {
    $agentsSource = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "AGENTS.md"))
    $workflowsSource = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot "workflows"))
    $CodexHome = [System.IO.Path]::GetFullPath($CodexHome)
    $WorkflowsRoot = [System.IO.Path]::GetFullPath($WorkflowsRoot)
    $agentsTarget = Join-Path $CodexHome "AGENTS.md"

    if (-not (Test-Path -LiteralPath $agentsSource -PathType Leaf)) {
        throw "AGENTS.md not found: $agentsSource"
    }
    if (-not (Test-Path -LiteralPath $workflowsSource -PathType Container)) {
        throw "Workflows directory not found: $workflowsSource"
    }

    $override = Join-Path $CodexHome "AGENTS.override.md"
    if ($null -ne (Get-Item -LiteralPath $override -Force -ErrorAction SilentlyContinue)) {
        throw "Resolve $override manually before installing; it can shadow AGENTS.md."
    }

    foreach ($target in @($agentsTarget, $WorkflowsRoot)) {
        if ($null -ne (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue)) {
            throw "Target already exists: $target"
        }
    }

    New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $WorkflowsRoot) | Out-Null

    try {
        New-Item -ItemType Junction -Path $WorkflowsRoot -Target $workflowsSource | Out-Null
        New-Item -ItemType SymbolicLink -Path $agentsTarget -Target $agentsSource | Out-Null
    } catch {
        if ($null -ne (Get-Item -LiteralPath $agentsTarget -Force -ErrorAction SilentlyContinue)) {
            Remove-Item -LiteralPath $agentsTarget -Force
        }
        if ($null -ne (Get-Item -LiteralPath $WorkflowsRoot -Force -ErrorAction SilentlyContinue)) {
            Remove-Item -LiteralPath $WorkflowsRoot -Force
        }
        throw
    }

    Write-Host "[link] workflows -> $workflowsSource"
    Write-Host "[link] AGENTS.md -> $agentsSource"
    Write-Host "Start a new Codex session to load the instructions."
}
