# agent-skills

Personal agent skills and global instructions, shared through Git across computers and coding-agent harnesses.

## Minimal setup for GPT-6.2

Select the intended GPT-6.2 model in the harness. These files inherit that runtime choice; neither YAML nor a skill prompt switches the main model. There are no mandatory per-stage models or reasoning levels.

The default is a small set of global rules and only the skill needed for the current request. Factory keeps one OpenSpec change, one owner for the connected implementation, focused behavioral checks and one independent review before owner acceptance. Existing project requirements and required CI checks still apply.

Removed from the routine path: duplicate plans, mandatory interview/spec-polish chains, three-pass ensemble review, a second local/external review by default, and repeated full checks after every small repair. Supporting skills remain available on explicit request; no skill was deleted.

### Optional skills retained for the trial

| Skill | When it still helps |
| --- | --- |
| `coding-quality` | A requested design/complexity review; ordinary implementation follows the short global rules. |
| `ensemble-code-review` | An explicitly requested comparison of three independent review perspectives. |
| `openspec-review-change` | A spec with material uncertainty that merits separate review. |
| `openspec-summarize-change` | A requested explanation of a change for its owner. |
| `openspec-retrospective` (`openspec-retro-change/`) | Analyzing time, rework, verification cost and review value from an actual delivery. |
| `to-changes` | Splitting broad requirements into useful deliverable changes. |
| `verify-feature` | A focused check of whether implemented behavior satisfies requirements. |

The first four are candidates to stop using routinely while trying this setup. The installer still links their files; the global routing and Factory no longer require them. Judge the setup on the next real task: time to a reviewable PR, unnecessary changes and defects found after acceptance. Replaying a task through several setups is not a prerequisite.

This direction follows the official [GPT-6.2 prompting guide](https://learn.chatgpt.com/guides/prompting-gpt-6-2-astra) and [guidance on simplifying skills](https://learn.chatgpt.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). Reduced instruction volume is measurable; faster or more reliable development still needs evidence from real work.

## Install

Clone into a stable directory. The installer links `AGENTS.md`, `skills/` and `workflows/` into the selected harness configuration directory.

| Harness | Global directory | Windows | macOS / Linux |
| --- | --- | --- | --- |
| Codex | `~/.codex` | `.\install.ps1 -Agent codex` | `sh ./install.sh codex` |
| Pi | `~/.pi/agent` | `.\install.ps1 -Agent pi` | `sh ./install.sh pi` |
| OpenCode | `~/.config/opencode` | `.\install.ps1 -Agent opencode` | `sh ./install.sh opencode` |

Windows uses directory junctions and a file symlink for `AGENTS.md`; the latter can require Developer Mode or appropriate privileges. macOS/Linux uses symlinks. Do not install from a disposable worktree.

Existing targets are preserved. The installer reports `[link]`, `[skip]` or `[error]` for each target and continues with the others. When `skills/` already exists, missing skills are linked individually; existing skills/files/links remain intact. For Codex, missing skill links are also added to `~/.agents/skills` when that directory already exists.

When the whole skills directory is linked, `git pull` exposes added skills automatically. With individual skill links, rerun the installer to add new directories. Existing linked files receive their updated contents from the stable checkout.

## Machine-specific configuration

Factory's `profile.yaml` is optional and ignored by Git. Use [profile.example.yaml](skills/factory/profile.example.yaml) only for machine-specific provider/store/ranking bindings. Keep credentials in authenticated tools and private service IDs out of this public repository.

**Existing version-1 profiles need migration before Factory writes.** Git updates preserve the local file. Follow the [field mapping](skills/factory/references/profile.md#migrating-an-existing-version-1-profile): keep service bindings and required reviews, remove per-stage model/skill routing, and select the model in the host. Do not replace a work profile with the GitHub example. Read-only `status` remains available during migration.

Native OpenSpec proposal/apply/archive skills and the OpenSpec CLI are external prerequisites when Factory reaches those actions. This repository does not install or replace them. Workflows under `workflows/` are targeted references, loaded only when useful.

## Adding a skill

Add `skills/<name>/SKILL.md`, keep its trigger narrow and its unique instructions short, then commit it. Store optional detailed references beside the skill. Keep machine-local configuration ignored and publish only safe example values.
