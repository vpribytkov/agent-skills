# agent-skills

Personal collection of reusable agent skills and global instructions, kept in Git so the same workflows can be used across multiple computers and repositories.

The repository is the source of truth for the skill definitions. Installation does **not** copy skills into the agent store: it creates one link per skill, so a normal `git pull` updates the installed skills immediately.

## Layout

```text
agent-skills/
├── AGENTS.md
├── references/
│   └── codegraph.md
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

`references/codegraph.md` is the supplied third-party tool reference, kept unchanged,
not an installable skill. Its routing and local usage constraints remain in `AGENTS.md`.
Only the workflows routed by the supplied profiles are activated; the unused
`frontend.md` and superseded `pr.md` are not installed as new skills.

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
It also applies when working in this repository. The ordinary install commands
above still install **skills only**. To also install the global instructions and
their CodeGraph reference on each computer:

```powershell
.\install.ps1 -InstallAgents
```

```bash
sh ./install.sh --agents
```

The destinations are `$CODEX_HOME/AGENTS.md` and `$CODEX_HOME/references/codegraph.md`
when `CODEX_HOME` is set, otherwise the same paths under `~/.codex`.
Override the home with `-CodexHome <directory>` or `--codex-home <directory>`.
`-TargetRoot` / the positional shell directory still controls only the skill store;
Codex must be configured to discover a custom store.

Both installers prefer **file symlinks**, not hard links. On Windows, unlike the
skill-directory junctions, file symlinks can require Developer Mode or appropriate
privileges. There is no silent fallback or privilege escalation. If symlinks are
not permitted, explicitly select copy mode for both instruction files:

```powershell
.\install.ps1 -InstallAgents -AgentsMode Copy
```

```bash
sh ./install.sh --agents --copy
```

### First migration and safety

Existing regular instruction/reference files are not replaced unless explicitly requested:

```powershell
.\install.ps1 -InstallAgents -ReplaceAgents
# For a machine where file symlinks are unavailable:
.\install.ps1 -InstallAgents -AgentsMode Copy -ReplaceAgents
```

```bash
sh ./install.sh --agents --replace-agents
# Copy mode:
sh ./install.sh --agents --copy --replace-agents
```

Replacement preserves each old file beside it as `<filename>.backup.<unique-id>`.
The installer checks both destinations before replacing either file, then installs
the reference before activating `AGENTS.md`. Each new link/copy is staged before
moving its old file; that file is restored if activation fails. This is per-file
recovery, not a transaction spanning both files; an already installed reference
can remain after a later failure. Rerunning is safe. Correct links and identical
copies are left unchanged.
Directories and foreign/dangling links are refused even with the replacement flag.
To deliberately switch an existing symlink to copy mode, remove **only that link**
yourself, then run copy installation. Do not remove its source file.

Any `AGENTS.override.md` (including an empty file or dangling link) blocks global
installation until resolved manually: an override can shadow the shared rules.
The installer never changes it, `config.toml`, authentication files, or unrelated
Codex state. Skill collisions stop the command before global installation;
previously created skill links can remain and rerunning is safe.

After migration, start a **new Codex session** and ask it to summarize its active
instructions. Do not assume an existing chat has reloaded the file.
The new router uses installed skills and the installed CodeGraph reference, not the
old `~/.agents/workflows/` or `tools/` files. Keep those old files until the new
session is verified, then remove unused copies manually. The installer does not
delete them or install CLI/MCP tools.

If an earlier draft was installed, remove only its obsolete managed links to
`instructions/AGENTS.md`, `skills/frontend`, and `skills/codegraph` before reinstalling.
Do not remove unrelated local skills or the links' source files.

### Synchronizing the global files

Edit `AGENTS.md` or `references/codegraph.md` in this checkout, commit and push the
change, then run `git pull` on the other computer. With symlinks, this updates the
files used by new sessions. With copy mode, rerun the copy command with the
replacement flag; each changed copy gets a backup. Run the installer after pulling
newly added skills so their directory links are created too. Git does not pull automatically.

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

The tests use disposable homes and check resulting files, link targets, preserved
bytes, collisions, copy updates, and failure recovery. They do not touch your real
agent configuration. Python is a test-only dependency, not an installation dependency.

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
