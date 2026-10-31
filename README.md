# agent-skills

Personal collection of reusable agent skills and global instructions, kept in Git so the same setup can be used across multiple computers and coding-agent harnesses.

## Layout

```text
agent-skills/
├── AGENTS.md
├── workflows/
│   ├── planning.md
│   ├── investigation-rca.md
│   ├── integration-tests.md
│   └── observability.md
├── skills/
│   ├── coding-quality/
│   ├── create-pr/
│   ├── factory/
│   ├── openspec-*/
│   ├── ponytail/
│   └── ...
├── install.ps1
└── install.sh
```

The installer always links all three parts — `skills/`, `workflows/`, and `AGENTS.md` — into the selected harness configuration directory.

Supported harnesses:

| Agent | Global directory |
| --- | --- |
| Codex | `~/.codex` |
| Pi | `~/.pi/agent` |
| OpenCode | `~/.config/opencode` |

These locations match the harnesses' global instruction directories. Codex skills use `~/.codex/skills`; Pi and OpenCode also support their native global skill directories used here.

## Install

Clone this repository into a stable location, then select the harness.

### Windows

```powershell
.\install.ps1 -Agent codex
.\install.ps1 -Agent pi
.\install.ps1 -Agent opencode
```

Directory targets are installed as junctions. `AGENTS.md` is installed as a file symlink, which can require Developer Mode or appropriate privileges.

### macOS / Linux

```bash
sh ./install.sh codex
sh ./install.sh pi
sh ./install.sh opencode
```

All targets are symlinks.

The resulting layout for the selected harness is:

```text
<agent-root>/
├── AGENTS.md   -> <repo>/AGENTS.md
├── skills/     -> <repo>/skills/
└── workflows/  -> <repo>/workflows/
```

The installer never replaces an existing target. Missing targets are linked and reported as `[link]`, occupied paths are reported as `[skip]`, and link failures are reported as `[error]`. One occupied target does not prevent the installer from linking the others.

If the selected harness already has a `skills/` directory, the installer adds an individual link for each missing skill instead of skipping the whole directory. Existing skills, files, and links are preserved. This also works when `skills/` is a directory link to a shared location.

For Codex, the installer also adds missing skill links to `~/.agents/skills` if that directory already exists. This keeps installations made by earlier versions of these scripts up to date.

Do not install from a temporary worktree that will be deleted. Use a stable checkout.

## Adding a skill

Add a new directory under `skills/` and commit it:

```text
skills/
└── my-skill/
    └── SKILL.md
```

When the whole `skills/` directory is linked, newly added skills appear after `git pull` automatically. When skills are linked individually into an existing directory, rerun the installer after `git pull` to add links for new skills:

```powershell
.\install.ps1 -Agent codex
```

```bash
sh ./install.sh codex
```

Use `pi` or `opencode` instead of `codex` for the other harnesses.

## Ponytail in Factory

`skills/ponytail/SKILL.md` is a [scoped adaptation of Ponytail](https://github.com/DietrichGebert/ponytail/blob/96608e078b2d5ea607c5c3b8b5a54d1c1fba6846/skills/ponytail/SKILL.md), licensed under MIT (see `skills/ponytail/LICENSE`). Factory explicitly loads it for Develop, including repairs. It does not install Ponytail's plugin hooks or inject rules into Review.

After installing or pulling updates on Windows, verify the Codex paths:

```powershell
Get-Item "$HOME\.codex\AGENTS.md" -Force | Select-Object LinkType, Target
Test-Path "$HOME\.codex\skills\ponytail\SKILL.md"
```

If `AGENTS.md` was reported as `[skip]`, the installer intentionally preserved the existing file. Check that it links to this repository; reconcile it manually if not.

## Machine-specific configuration

Keep machine-specific values, credentials, private service identifiers, and other secrets out of this repository.

If a skill needs machine-local configuration, keep a tracked `profile.example.yaml` (or equivalent template) and an ignored local `profile.yaml`. Do not commit secrets to this public repository.
