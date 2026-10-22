param(
    [string]$SkillsRoot = (Join-Path $HOME ".agents\skills"),
    [string]$WorkflowsRoot = (Join-Path $HOME ".agents\workflows"),
    [string]$AgentsPath = (Join-Path $HOME ".codex\AGENTS.md")
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

$SkillsRoot = [System.IO.Path]::GetFullPath($SkillsRoot)
$WorkflowsRoot = [System.IO.Path]::GetFullPath($WorkflowsRoot)
$AgentsPath = [System.IO.Path]::GetFullPath($AgentsPath)

New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null

Get-ChildItem -LiteralPath $SkillsSource -Directory | ForEach-Object {
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

Get-ChildItem -LiteralPath $SkillsSource -Directory | Sort-Object Name | ForEach-Object {
    $source = [System.IO.Path]::GetFullPath($_.FullName)
    $target = Join-Path $SkillsRoot $_.Name
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
Write-Host "Installed skill links in: $SkillsRoot"
Write-Host "Created: $created; already correct: $existing; collisions: $collisions"

if ($collisions -gt 0) {
    exit 2
}

foreach ($target in @($WorkflowsRoot, $AgentsPath)) {
    if ($null -ne (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue)) {
        throw "Target already exists: $target"
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $WorkflowsRoot) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $AgentsPath) | Out-Null

try {
    New-Item -ItemType Junction -Path $WorkflowsRoot -Target $WorkflowsSource | Out-Null
    New-Item -ItemType SymbolicLink -Path $AgentsPath -Target $AgentsSource | Out-Null
} catch {
    if ($null -ne (Get-Item -LiteralPath $AgentsPath -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $AgentsPath -Force
    }
    if ($null -ne (Get-Item -LiteralPath $WorkflowsRoot -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $WorkflowsRoot -Force
    }
    throw
}

Write-Host "[link] workflows -> $WorkflowsSource"
Write-Host "[link] AGENTS.md -> $AgentsSource"
