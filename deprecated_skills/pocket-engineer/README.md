# pocket-engineer

`pocket-engineer` is an explicitly invoked Codex skill for running software work through five gated phases:

`ANALYSIS → DESIGN → DEVELOPMENT → TESTING → RELEASE_READY`

Each phase uses its own workflow and agent profile. The orchestrator waits for explicit approval before advancing.

## Install

The commands below clone the skill into the shared user skill directory and link its five agent profiles into Codex. Restart Codex after installation so it reloads the skill and profiles.

### Windows PowerShell

```powershell
$skillDir = Join-Path $HOME ".agents\skills\pocket-engineer"
New-Item -ItemType Directory -Force (Split-Path $skillDir) | Out-Null
git clone https://github.com/vpribytkov/pocket-engineer.git $skillDir
& "$skillDir\scripts\init.cmd"
```

Creating symbolic links on Windows requires Developer Mode or an elevated shell. If `CODEX_HOME` is set, the profiles are linked into `$env:CODEX_HOME\agents`; otherwise they are linked into `$HOME\.codex\agents`.

### macOS or Linux

```sh
skill_dir="$HOME/.agents/skills/pocket-engineer"
mkdir -p "$(dirname "$skill_dir")"
git clone https://github.com/vpribytkov/pocket-engineer.git "$skill_dir"
sh "$skill_dir/scripts/init.sh"
```

If `CODEX_HOME` is set, the profiles are linked into `$CODEX_HOME/agents`; otherwise they are linked into `$HOME/.codex/agents`.

## Use

Explicitly invoke `pocket-engineer` for a software task. At each checkpoint, use the approval command requested by the skill, such as `APPROVE ANALYSIS`, or request a revision with `REVISE: <feedback>`.

## Update

```sh
git -C "$HOME/.agents/skills/pocket-engineer" pull --ff-only
```

The installed agent-profile links continue to point at the updated files.
