$ErrorActionPreference = "Stop"

$InstallerSource = Join-Path (Split-Path -Parent $PSScriptRoot) "install.ps1"
$TestRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("agent skills install-" + [guid]::NewGuid())
$PowerShellPath = (Get-Process -Id $PID).Path
$Failures = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

function Assert-Link {
    param([string]$Path, [string]$Source, [string]$Type = "Junction")
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    Assert-True ($null -ne $item -and $item.LinkType -eq $Type) "Expected $Type at $Path"
    Assert-True (@($item.Target)[0] -eq $Source) "Unexpected link target at $Path"
}

function New-Fixture {
    param([string]$Name, [string]$Agent)
    $root = Join-Path $TestRoot $Name
    $repo = Join-Path $root "repo"
    $userRoot = Join-Path $root "user"
    New-Item -ItemType Directory -Path (Join-Path $repo "skills\original"), (Join-Path $repo "workflows"), $userRoot -Force | Out-Null
    Copy-Item -LiteralPath $InstallerSource -Destination (Join-Path $repo "install.ps1")
    Set-Content -LiteralPath (Join-Path $repo "skills\original\SKILL.md") -Value "original skill"
    Set-Content -LiteralPath (Join-Path $repo "AGENTS.md") -Value "fixture instructions"
    $relativeRoot = switch ($Agent) {
        "codex" { ".codex" }
        "pi" { ".pi\agent" }
        "opencode" { ".config\opencode" }
    }
    $agentRoot = Join-Path $userRoot $relativeRoot
    # A pre-existing instructions file keeps skill tests runnable without symlink privileges.
    New-Item -ItemType Directory -Path $agentRoot -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $agentRoot "AGENTS.md") -Value "local instructions"
    return @{ Repo = $repo; UserRoot = $userRoot; AgentRoot = $agentRoot; Agent = $Agent }
}

function Invoke-Installer {
    param([hashtable]$Fixture)
    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = $PowerShellPath
    $start.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $Fixture.Repo "install.ps1") + '" -Agent ' + $Fixture.Agent
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.EnvironmentVariables["USERPROFILE"] = $Fixture.UserRoot
    $process = [System.Diagnostics.Process]::Start($start)
    $output = $process.StandardOutput.ReadToEnd()
    $errors = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    Assert-True ($process.ExitCode -eq 0) "Installer failed: $output $errors"
}

function Add-Skill {
    param([hashtable]$Fixture, [string]$Name)
    $path = Join-Path $Fixture.Repo "skills\$Name"
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $path "SKILL.md") -Value "$Name content"
}

function Test-Case {
    param([string]$Name, [scriptblock]$Body)
    try {
        & $Body
        Write-Host "PASS $Name"
    } catch {
        $script:Failures += "$Name`: $($_.Exception.Message)"
        Write-Host "FAIL $Name`: $($_.Exception.Message)"
    }
}

try {
    foreach ($agent in @("codex", "pi", "opencode")) {
        Test-Case "$agent fresh skills directory and automatic updates" {
            $fixture = New-Fixture "$agent-fresh" $agent
            Invoke-Installer $fixture
            Assert-Link (Join-Path $fixture.AgentRoot "skills") (Join-Path $fixture.Repo "skills")
            Assert-Link (Join-Path $fixture.AgentRoot "workflows") (Join-Path $fixture.Repo "workflows")
            Assert-True ((Get-Content -LiteralPath (Join-Path $fixture.AgentRoot "AGENTS.md")) -eq "local instructions") "Existing instructions were changed"
            Add-Skill $fixture "new skill"
            Assert-True ((Get-Content -LiteralPath (Join-Path $fixture.AgentRoot "skills\new skill\SKILL.md")) -eq "new skill content") "New skill is not visible through the directory link"
            Invoke-Installer $fixture
            Assert-Link (Join-Path $fixture.AgentRoot "skills") (Join-Path $fixture.Repo "skills")
            Assert-True (-not (Test-Path -LiteralPath (Join-Path $fixture.UserRoot ".agents"))) "Fresh installation unexpectedly created a shared skills root"
        }

        Test-Case "$agent existing directory, new skills and conflicts" {
            $fixture = New-Fixture "$agent-existing" $agent
            $skills = Join-Path $fixture.AgentRoot "skills"
            New-Item -ItemType Directory -Path (Join-Path $skills ".system"), (Join-Path $skills "occupied") -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $skills ".system\keep.txt") -Value "system sentinel"
            Set-Content -LiteralPath (Join-Path $skills "occupied\SKILL.md") -Value "local skill"
            Set-Content -LiteralPath (Join-Path $skills "file-conflict") -Value "local file"
            New-Item -ItemType Junction -Path (Join-Path $skills "original") -Target (Join-Path $fixture.Repo "skills\original") | Out-Null
            $missing = Join-Path $fixture.UserRoot "removed"
            New-Item -ItemType Directory -Path $missing | Out-Null
            New-Item -ItemType Junction -Path (Join-Path $skills "broken") -Target $missing | Out-Null
            Remove-Item -LiteralPath $missing -Force
            Invoke-Installer $fixture
            foreach ($name in @("new skill", "second-new", "occupied", "file-conflict", "broken")) { Add-Skill $fixture $name }
            Invoke-Installer $fixture
            foreach ($name in @("original", "new skill", "second-new")) {
                Assert-Link (Join-Path $skills $name) (Join-Path $fixture.Repo "skills\$name")
            }
            Assert-True ((Get-Content -LiteralPath (Join-Path $skills "new skill\SKILL.md")) -eq "new skill content") "Linked skill is not readable"
            Assert-True ((Get-Content -LiteralPath (Join-Path $skills "occupied\SKILL.md")) -eq "local skill") "Existing skill was overwritten"
            Assert-True ((Get-Content -LiteralPath (Join-Path $skills "file-conflict")) -eq "local file") "Existing file was overwritten"
            Assert-True ((Get-Content -LiteralPath (Join-Path $skills ".system\keep.txt")) -eq "system sentinel") "System skills were changed"
            Assert-Link (Join-Path $skills "broken") $missing
            Invoke-Installer $fixture
            Assert-Link (Join-Path $skills "new skill") (Join-Path $fixture.Repo "skills\new skill")
        }

        Test-Case "$agent skills directory alias" {
            $fixture = New-Fixture "$agent-alias" $agent
            $shared = Join-Path $fixture.UserRoot "shared"
            New-Item -ItemType Directory -Path $shared, $fixture.AgentRoot -Force | Out-Null
            New-Item -ItemType Junction -Path (Join-Path $fixture.AgentRoot "skills") -Target $shared | Out-Null
            Invoke-Installer $fixture
            Assert-Link (Join-Path $shared "original") (Join-Path $fixture.Repo "skills\original")
            Assert-Link (Join-Path $fixture.AgentRoot "skills") $shared
        }

        Test-Case "$agent occupied skills file does not block other targets" {
            $fixture = New-Fixture "$agent-file" $agent
            New-Item -ItemType Directory -Path $fixture.AgentRoot -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $fixture.AgentRoot "skills") -Value "keep file"
            Invoke-Installer $fixture
            Assert-True ((Get-Content -LiteralPath (Join-Path $fixture.AgentRoot "skills")) -eq "keep file") "Occupied skills file was changed"
            Assert-Link (Join-Path $fixture.AgentRoot "workflows") (Join-Path $fixture.Repo "workflows")
            Assert-True ((Get-Content -LiteralPath (Join-Path $fixture.AgentRoot "AGENTS.md")) -eq "local instructions") "Existing instructions were changed"
        }
    }

    Test-Case "codex existing shared skills from the previous installer" {
        $fixture = New-Fixture "codex-legacy" "codex"
        $shared = Join-Path $fixture.UserRoot ".agents\skills"
        New-Item -ItemType Directory -Path $shared, (Join-Path $fixture.AgentRoot "skills\.system") -Force | Out-Null
        New-Item -ItemType Junction -Path (Join-Path $shared "original") -Target (Join-Path $fixture.Repo "skills\original") | Out-Null
        Invoke-Installer $fixture
        Add-Skill $fixture "new skill"
        Add-Skill $fixture "second-new"
        Invoke-Installer $fixture
        foreach ($name in @("new skill", "second-new")) {
            Assert-Link (Join-Path $shared $name) (Join-Path $fixture.Repo "skills\$name")
            Assert-True ((Get-Content -LiteralPath (Join-Path $shared "$name\SKILL.md")) -eq "$name content") "Shared skill is not readable"
        }
        Assert-True ((Get-Item -LiteralPath $shared).LinkType -eq $null) "Shared directory was replaced"
    }

    if ($Failures.Count -gt 0) { throw "$($Failures.Count) installer test(s) failed." }
} finally {
    if (Test-Path -LiteralPath $TestRoot) {
        if ((Resolve-Path -LiteralPath $TestRoot).ProviderPath -ne $TestRoot) { throw "Unexpected cleanup path: $TestRoot" }
        Remove-Item -LiteralPath $TestRoot -Recurse -Force
    }
}
