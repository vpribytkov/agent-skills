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

The installer never replaces an existing target. It checks all three targets independently: existing targets are reported as `[skip]`, missing targets are linked and reported as `[link]`, and link failures are reported as `[error]`. One occupied target does not prevent the installer from linking the others.

Because all three targets point directly at this checkout, changes become visible after `git pull` without reinstalling.

Do not install from a temporary worktree that will be deleted. Use a stable checkout.

## Adding a skill

Add a new directory under `skills/` and commit it:

```text
skills/
└── my-skill/
    └── SKILL.md
```

Because the whole `skills/` directory is linked, newly added skills appear after `git pull` without rerunning the installer.

## Machine-specific configuration

Keep machine-specific values, credentials, private service identifiers, and other secrets out of this repository.

If a skill needs machine-local configuration, keep a tracked `profile.example.yaml` (or equivalent template) and an ignored local `profile.yaml`. Do not commit secrets to this public repository.
