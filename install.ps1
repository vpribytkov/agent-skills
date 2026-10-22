param(
    [string]$TargetRoot = (Join-Path $HOME ".agents\skills"),
    [switch]$InstallAgents,
    [ValidateSet("Link", "Copy")][string]$AgentsMode = "Link",
    [switch]$ReplaceAgents,
    [string]$WorkflowsRoot = (Join-Path $HOME ".agents\workflows"),
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" })
)

$ErrorActionPreference = "Stop"
if (-not $InstallAgents -and ($ReplaceAgents -or $PSBoundParameters.ContainsKey("AgentsMode") -or $PSBoundParameters.ContainsKey("WorkflowsRoot") -or $PSBoundParameters.ContainsKey("CodexHome"))) {
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
    $CodexHome = [System.IO.Path]::GetFullPath($CodexHome)
    New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
    $override = Join-Path $CodexHome "AGENTS.override.md"
    if ($null -ne (Get-Item -LiteralPath $override -Force -ErrorAction SilentlyContinue)) {
        throw "Resolve $override manually before installing; it can shadow AGENTS.md."
    }

    function Install-ManagedFile {
        param(
            [string]$Source,
            [string]$Target,
            [ValidateSet("Link", "Copy")][string]$FileMode,
            [switch]$CheckOnly
        )

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
            if (-not $ReplaceAgents) {
                throw "Existing file: $Target. Use -ReplaceAgents to back it up and replace it."
            }
        }

        if ($CheckOnly) { return }

        New-Item -ItemType Directory -Force -Path $parent | Out-Null
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

    $managed = @(
        @{ Source = (Join-Path $RepoRoot "workflows\planning.md"); Target = (Join-Path $WorkflowsRoot "planning.md"); Mode = "Copy" },
        @{ Source = (Join-Path $RepoRoot "workflows\investigation-rca.md"); Target = (Join-Path $WorkflowsRoot "investigation-rca.md"); Mode = "Copy" },
        @{ Source = (Join-Path $RepoRoot "workflows\integration-tests.md"); Target = (Join-Path $WorkflowsRoot "integration-tests.md"); Mode = "Copy" },
        @{ Source = (Join-Path $RepoRoot "workflows\observability.md"); Target = (Join-Path $WorkflowsRoot "observability.md"); Mode = "Copy" },
        @{ Source = (Join-Path $RepoRoot "workflows\openspec.md"); Target = (Join-Path $WorkflowsRoot "openspec.md"); Mode = "Copy" },
        @{ Source = (Join-Path $RepoRoot "AGENTS.md"); Target = (Join-Path $CodexHome "AGENTS.md"); Mode = $AgentsMode }
    )

    foreach ($file in $managed) {
        Install-ManagedFile -Source $file.Source -Target $file.Target -FileMode $file.Mode -CheckOnly
    }
    foreach ($file in $managed) {
        Install-ManagedFile -Source $file.Source -Target $file.Target -FileMode $file.Mode
    }

    Write-Host "Start a new Codex session to load the instructions."
}
