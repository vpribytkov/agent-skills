# agent-skills

Personal collection of reusable agent skills, kept in Git so the same workflows can be used across multiple computers and repositories.

The repository is the source of truth for the skill definitions. Installation does **not** copy skills into the agent store: it creates one link per skill, so a normal `git pull` updates the installed skills immediately.

## Layout

```text
agent-skills/
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

## Collision policy

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

If a skill needs machine-local configuration (for example a home/work factory profile), keep the reusable skill definition in Git and treat the machine-local configuration separately. Do not commit secrets to this public repository.

## Design goals

- one Git repository for reusable skills;
- no manual copying between computers;
- no takeover of the entire agent skill directory;
- safe coexistence with local-only skills;
- updates through ordinary Git operations;
- Windows and Unix-like installation paths supported.
