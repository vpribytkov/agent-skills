param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [string]$WorkflowsRoot = (Join-Path $HOME ".agents\workflows"),
    [ValidateSet("Link", "Copy")][string]$Mode = "Link",
    [switch]$Replace
)

$ErrorActionPreference = "Stop"
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$CodexHome = [System.IO.Path]::GetFullPath($CodexHome)
New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$override = Join-Path $CodexHome "AGENTS.override.md"
# Get-Item also detects dangling links; never follow or replace an override.
if ($null -ne (Get-Item -LiteralPath $override -Force -ErrorAction SilentlyContinue)) {
    throw "Resolve $override manually before installing; it can shadow AGENTS.md."
}

function Install-InstructionFile {
    param([string]$Source, [string]$Target, [ValidateSet("Link", "Copy")][string]$FileMode = $Mode, [switch]$CheckOnly)

    $name = Split-Path -Leaf $Target
    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $Source -PathType Leaf) -or (Get-Item -LiteralPath $Source).Length -eq 0) {
        throw "Missing or empty source: $Source"
    }
    if ($Target -eq $Source) {
        throw "Source and destination must be different."
    }
    $current = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($null -ne $current) {
        if ($current.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $linkTarget = $null
            if ($current.LinkType -eq "SymbolicLink" -and $current.Target) {
                $linkTarget = @($current.Target)[0]
                if (-not [System.IO.Path]::IsPathRooted($linkTarget)) {
                    $linkTarget = Join-Path $parent $linkTarget
                }
                $linkTarget = [System.IO.Path]::GetFullPath($linkTarget)
            }
            if ($FileMode -eq "Link" -and $linkTarget -eq $Source) {
                if (-not $CheckOnly) { Write-Host "[ok]   $name -> $Source" }
                return
            }
            throw "Refusing to replace a link: $Target. Resolve it manually."
        }
        if ($current.PSIsContainer) {
            throw "Refusing to replace a directory: $Target"
        }
        if ($FileMode -eq "Copy" -and (Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Target).Hash) {
            if (-not $CheckOnly) { Write-Host "[ok]   $name copy is current" }
            return
        }
        if (-not $Replace) {
            throw "Existing file: $Target. Use -ReplaceAgents to back it up and replace it."
        }
    }
    if ($CheckOnly) { return }

    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    # Stage first, so missing symlink privileges leave the existing file untouched.
    $id = [guid]::NewGuid().ToString("N")
    $stage = Join-Path $parent ".agents-install-$id"
    $backup = $null
    New-Item -ItemType Directory -Path $stage | Out-Null
    $stagedFile = Join-Path $stage $name
    try {
        if ($FileMode -eq "Link") {
            try {
                New-Item -ItemType SymbolicLink -Path $stagedFile -Target $Source | Out-Null
            } catch {
                throw "Cannot create the file symlink. Enable permitted symlink support or rerun with -AgentsMode Copy. Existing $name was not changed. $($_.Exception.Message)"
            }
        } else {
            Copy-Item -LiteralPath $Source -Destination $stagedFile
        }
        if ($null -ne $current) {
            $backup = "$Target.backup.$id"
            Move-Item -LiteralPath $Target -Destination $backup
        }
        Move-Item -LiteralPath $stagedFile -Destination $Target
        if ($backup) { Write-Host "[backup] $backup" }
        $backup = $null
        Write-Host "[$FileMode] $name -> $Target"
    } finally {
        if ($backup -and $null -eq (Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue)) {
            Move-Item -LiteralPath $backup -Destination $Target
        }
        if ($null -ne (Get-Item -LiteralPath $stagedFile -Force -ErrorAction SilentlyContinue)) {
            Remove-Item -LiteralPath $stagedFile -Force
        }
        Remove-Item -LiteralPath $stage
    }
}

# Check every managed destination before replacing any file; activate AGENTS.md last.
$specs = @(
    @{ Source = (Join-Path $RepoRoot "workflows\planning.md"); Target = (Join-Path $WorkflowsRoot "planning.md"); FileMode = "Copy" },
    @{ Source = (Join-Path $RepoRoot "workflows\investigation-rca.md"); Target = (Join-Path $WorkflowsRoot "investigation-rca.md"); FileMode = "Copy" },
    @{ Source = (Join-Path $RepoRoot "workflows\integration-tests.md"); Target = (Join-Path $WorkflowsRoot "integration-tests.md"); FileMode = "Copy" },
    @{ Source = (Join-Path $RepoRoot "workflows\observability.md"); Target = (Join-Path $WorkflowsRoot "observability.md"); FileMode = "Copy" },
    @{ Source = (Join-Path $RepoRoot "workflows\openspec.md"); Target = (Join-Path $WorkflowsRoot "openspec.md"); FileMode = "Copy" },
    @{ Source = (Join-Path $RepoRoot "AGENTS.md"); Target = (Join-Path $CodexHome "AGENTS.md"); FileMode = $Mode }
)
foreach ($spec in $specs) {
    Install-InstructionFile -Source $spec.Source -Target $spec.Target -FileMode $spec.FileMode -CheckOnly
}
foreach ($spec in $specs) {
    Install-InstructionFile -Source $spec.Source -Target $spec.Target -FileMode $spec.FileMode
}
Write-Host "Start a new Codex session to load the instructions."
