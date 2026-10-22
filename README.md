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

The installer always installs all three parts:

- skill directories;
- the shared `workflows/` directory;
- the global `AGENTS.md`.

### Windows

```powershell
.\install.ps1
```

Default targets:

```text
~/.agents/skills
~/.agents/workflows
~/.codex/AGENTS.md
```

Override any target when another harness uses different paths:

```powershell
.\install.ps1 `
  -SkillsRoot "$HOME\.claude\skills" `
  -WorkflowsRoot "$HOME\.claude\workflows" `
  -AgentsPath "$HOME\.claude\AGENTS.md"
```

Skill and workflow directories use junctions. `AGENTS.md` uses a file symlink,
which can require Developer Mode or appropriate privileges on Windows.

### macOS / Linux

```bash
sh ./install.sh
```

Override targets explicitly when needed:

```bash
sh ./install.sh \
  --skills-root "$HOME/.claude/skills" \
  --workflows-root "$HOME/.claude/workflows" \
  --agents-path "$HOME/.claude/AGENTS.md"
```

Directories and `AGENTS.md` use symlinks.

### First migration and safety

The installer never replaces an existing `AGENTS.md` or workflows target. If either
target already exists, installation stops with an error. Move or remove the old file
or link explicitly, then rerun the installer.

The installer does not change `config.toml`, authentication files, or unrelated
harness state. Skill collisions stop the command before the global links are created;
previously created skill links can remain and rerunning is safe.

After migration, start a new session in harnesses that load global instructions
at session start. The router reads workflow files only when their conditions apply.
The installer does not install CLI/MCP tools.

### Synchronizing the global files

Edit `AGENTS.md` or a file under `workflows/` in this checkout, commit and push,
then run `git pull` on the other computer.
`AGENTS.md` and workflows both point directly at this checkout, so their changes
become visible after `git pull`. Run the installer after pulling newly added skills
so their directory links are created too.
Git does not pull automatically.

Do not link global instructions to a temporary worktree that will be deleted. Use a stable checkout.

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
