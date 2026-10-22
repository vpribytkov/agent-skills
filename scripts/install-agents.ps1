param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [ValidateSet("Link", "Copy")][string]$Mode = "Link",
    [switch]$Replace
)

$ErrorActionPreference = "Stop"
$source = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\instructions\AGENTS.md"))
if (-not (Test-Path -LiteralPath $source -PathType Leaf) -or (Get-Item -LiteralPath $source).Length -eq 0) {
    throw "Missing or empty source: $source"
}
$CodexHome = [System.IO.Path]::GetFullPath($CodexHome)
New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$target = Join-Path $CodexHome "AGENTS.md"
$override = Join-Path $CodexHome "AGENTS.override.md"
# Get-Item also detects dangling links; never follow or replace an override.
if ($null -ne (Get-Item -LiteralPath $override -Force -ErrorAction SilentlyContinue)) {
    throw "Resolve $override manually before installing; it can shadow AGENTS.md."
}
if ($target -eq $source) {
    throw "Source and destination must be different."
}
$current = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
if ($null -ne $current) {
    if ($current.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        $linkTarget = $null
        if ($current.LinkType -eq "SymbolicLink" -and $current.Target) {
            $linkTarget = @($current.Target)[0]
            if (-not [System.IO.Path]::IsPathRooted($linkTarget)) {
                $linkTarget = Join-Path $CodexHome $linkTarget
            }
            $linkTarget = [System.IO.Path]::GetFullPath($linkTarget)
        }
        if ($Mode -eq "Link" -and $linkTarget -eq $source) {
            Write-Host "[ok]   AGENTS.md -> $source"
            return
        }
        throw "Refusing to replace a link: $target. Resolve it manually."
    }
    if ($current.PSIsContainer) {
        throw "Refusing to replace a directory: $target"
    }
    if ($Mode -eq "Copy" -and (Get-FileHash -LiteralPath $source).Hash -eq (Get-FileHash -LiteralPath $target).Hash) {
        Write-Host "[ok]   AGENTS.md copy is current"
        return
    }
    if (-not $Replace) {
        throw "Existing file: $target. Use -ReplaceAgents to back it up and replace it."
    }
}

# Stage first, so missing symlink privileges leave the existing file untouched.
$id = [guid]::NewGuid().ToString("N")
$stage = Join-Path $CodexHome ".agents-install-$id"
$backup = $null
New-Item -ItemType Directory -Path $stage | Out-Null
$stagedFile = Join-Path $stage "AGENTS.md"
try {
    if ($Mode -eq "Link") {
        try {
            New-Item -ItemType SymbolicLink -Path $stagedFile -Target $source | Out-Null
        } catch {
            throw "Cannot create the file symlink. Enable permitted symlink support or rerun with -AgentsMode Copy. Existing AGENTS.md was not changed. $($_.Exception.Message)"
        }
    } else {
        Copy-Item -LiteralPath $source -Destination $stagedFile
    }
    if ($null -ne $current) {
        $backup = "$target.backup.$id"
        Move-Item -LiteralPath $target -Destination $backup
    }
    Move-Item -LiteralPath $stagedFile -Destination $target
    if ($backup) { Write-Host "[backup] $backup" }
    $backup = $null
    Write-Host "[$Mode] AGENTS.md -> $target"
    Write-Host "Start a new Codex session to load the instructions."
} finally {
    if ($backup -and $null -eq (Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue)) {
        Move-Item -LiteralPath $backup -Destination $target
    }
    if ($null -ne (Get-Item -LiteralPath $stagedFile -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $stagedFile -Force
    }
    Remove-Item -LiteralPath $stage
}
