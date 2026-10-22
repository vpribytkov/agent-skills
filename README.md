# agent-skills

Personal collection of reusable agent skills and global instructions, kept in Git so the same workflows can be used across multiple computers and repositories.

The repository is the source of truth for the skill definitions. Installation does **not** copy skills into the agent store: it creates one link per skill, so a normal `git pull` updates the installed skills immediately.

## Layout

```text
agent-skills/
├── AGENTS.md
├── workflows/
│   ├── planning.md
│   ├── investigation-rca.md
│   ├── integration-tests.md
│   ├── observability.md
│   └── openspec.md
├── skills/
│   ├── coding-quality/
│   ├── create-pr/
│   ├── factory/
│   ├── openspec-*/
│   └── ...
├── install.ps1
└── install.sh
```

Every direct subdirectory under `skills/` is treated as an installable skill. Files directly under `skills/` are ignored by the installers.

The `workflows/` directory is linked into `~/.agents/workflows/` when global
instructions are installed.

## Install

Clone the repository anywhere convenient:

```bash
git clone https://github.com/vpribytkov/agent-skills.git
cd agent-skills
```

### Windows

```powershell
.\install.ps1
```

The default target is:

```text
%USERPROFILE%\.agents\skills
```

The script creates a directory junction for every skill, which avoids copying files and normally does not require Developer Mode or administrator privileges.

To install into another skill store:

```powershell
.\install.ps1 -TargetRoot "$HOME\.claude\skills"
```

### macOS / Linux

```bash
sh ./install.sh
```

The default target is:

```text
~/.agents/skills
```

Pass another target as the first argument when needed:

```bash
sh ./install.sh ~/.claude/skills
```

## Global Codex instructions (opt-in)

The root `AGENTS.md` is the single source of truth for the work and home rules.
The ordinary install commands above still install **skills only**. To also install
the global instructions and workflow files:

```powershell
.\install.ps1 -InstallAgents
```

```bash
sh ./install.sh --agents
```

The global instruction destination is `$CODEX_HOME/AGENTS.md` when `CODEX_HOME`
is set, otherwise `~/.codex/AGENTS.md`. The repository `workflows/` directory
is linked to `~/.agents/workflows/`. `-WorkflowsRoot` / `--workflows-root`
overrides that directory when needed.

The workflows directory is linked like skill directories: a junction on Windows and
a symlink on macOS/Linux. `AGENTS.md` is a file symlink. On Windows, creating that
file symlink can require Developer Mode or appropriate privileges.

### First migration and safety

The installer never replaces an existing `AGENTS.md` or workflows target. If either
target already exists, installation stops with an error. Move or remove the old file
or link explicitly, then rerun the installer.

The installer does not change `config.toml`, authentication files, or unrelated
Codex state. Skill collisions stop the command before global installation;
previously created skill links can remain and rerunning is safe.

After migration, start a **new Codex session**; existing chats do not reload the
global file automatically. The router reads workflow files only when their conditions
apply. The installer does not install CLI/MCP tools.

### Synchronizing the global files

Edit `AGENTS.md` or a file under `workflows/` in this checkout, commit and push,
then run `git pull` on the other computer.
`AGENTS.md` and workflows both point directly at this checkout, so their changes
become visible after `git pull`. Run the installer after pulling newly added skills
so their directory links are created too.
Git does not pull automatically.

Do not link global instructions to a temporary worktree that will be deleted.
Use a stable checkout.

## Skill collision policy

The installers are deliberately conservative:

- an already-correct link is left unchanged;
- an existing real directory/file or a link to another source is **not** overwritten;
- collisions are reported and must be resolved manually.

This allows repository-managed skills to coexist with unrelated locally installed skills.

## Updating

Because installed skills point directly at this checkout, synchronization is just:

```bash
git pull
```

Changes become visible through the existing links immediately.

## Adding a skill

Add a new directory under `skills/` and commit it:

```text
skills/
└── my-skill/
    └── SKILL.md
```

Then rerun the installer on each machine. Existing links are kept; only missing skill links are created.

## Machine-specific configuration

Keep machine-specific values, credentials, private service identifiers, and other secrets out of this repository.

If a skill needs machine-local configuration, keep a tracked `profile.example.yaml` (or equivalent template) and an ignored local `profile.yaml`. The installers initialize the local profile only when it is missing and never overwrite it. Do not commit secrets to this public repository.

## Design goals

- one Git repository for reusable skills;
- no manual copying between computers;
- no takeover of the entire agent skill directory;
- safe coexistence with local-only skills;
- updates through ordinary Git operations;
- Windows and Unix-like installation paths supported.

## Installer verification

The tests use disposable homes and verify link targets, collision handling, and
rollback if creating the global file link fails. They do not touch the real agent
configuration. Python is a test-only dependency.

```bash
python3 tests/test_installers.py
```

On Windows, run against both supported PowerShell editions as available:

```powershell
python tests/test_installers.py --powershell powershell
python tests/test_installers.py --powershell pwsh
```

Symlink tests require symlink permission; lack of permission is a test failure,
not a reported pass. POSIX-only failure-injection checks are explicitly skipped
by the Windows test mode.

Codex discovery: [AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
and [skills](https://developers.openai.com/codex/skills).
Windows file links: [New-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item).
