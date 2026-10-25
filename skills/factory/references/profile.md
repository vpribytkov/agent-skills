# Machine-local profile

Read the one `profile.yaml` beside the installed SKILL.md. The repository tracks
`profile.example.yaml`; installation initializes the ignored machine-local
`profile.yaml` only when missing, and updates preserve it.
Do not auto-select a profile by repo, hostname, environment or command argument.

## Fields

| Field | Meaning |
| --- | --- |
| `version` | Schema version; v0 implementation accepts `1`. |
| `state.provider` | `work_items` for external receipts, or `filesystem` for local Markdown receipts and approvals. |
| `state.directory` | Required with filesystem receipts; one `<canonical-item-key>.md` per item. Expand `~` using the actual home directory. |
| `execution.concurrent_tasks` | `false` keeps one active job in provider scope; `true` allows independent jobs with isolated checkouts. |
| `work_items.provider` | Installed work-item provider, e.g. GitHub or Jira. |
| `work_items.identifiers` | Provider-owned scope, repository, board/project and status-field/option IDs. |
| `work_items.operations.read` | Tool/command binding to read one item and linked evidence. |
| `work_items.operations.candidates` | Read operation and scope/pagination for current candidates. |
| `work_items.operations.active` | Read operation covering unfinished jobs in the configured receipt store; needed to select or isolate the checkout even with concurrent jobs. |
| `work_items.operations.record` | Binding to persist receipts and links in `state.provider`; filesystem receipts do not imply work-item comments. |
| `work_items.transitions` | Provider-specific targets/actions for started, suspended, ready_to_merge and merged. No implied timing. |
| `repository.context` | Additional current project context paths; missing optional docs are reported/skipped. AGENTS.md always applies independently. |
| `repository.scope` | `current_checkout` binds execution to the open repository, independently of candidate-query scope. |
| `repository.worktree` | `never` does not create automatic worktrees; `when_parallel` creates/reuses one when another job occupies this repository's checkout. |
| `repository.openspec_store` | Registered fallback store ID for projects without local OpenSpec; null means no configured fallback. Actual paths come from the CLI. |
| `repository.openspec_command` | Machine's OpenSpec executable/path; preserve repository CLI constraints. |
| `repository.openspec_change_template` | Optional factory-side OpenSpec change-name template used before the proposal skill. Null preserves the proposal skill's native name derivation. Supported placeholders: `{item}`, `{item_lower}`, `{repository}`, `{service}`, `{slug}`. |
| `repository.branch_template` | Project branch convention; current repository instructions take precedence. |
| `prioritization_prompt` | Exact ranking policy; use a YAML literal block scalar rather than a folded scalar. |
| `blocks.<name>.enabled` | Enables a known block; only Review can be omitted in v0. |
| `blocks.<name>.model`, `reasoning` | Main-chat settings for Explore/Owner Review; dispatched executor settings for Develop/Review. |
| `blocks.<name>.skills` | Installed skill bindings for the roles used by that block. |
| `blocks.<name>.commands` | Alternative command/tool bindings for those same roles. |
| `blocks.develop.escalation` | Optional model, reasoning and technical escalation criterion. |
| `review.provider` | `skill_then_external` is the shared local-before-PR, external/CI-after-PR flow. `skill` (PR-only) and `ci` (external-only inside Develop) retain earlier explicit profile modes. |
| `review.identifiers` | Relevant review-agent/check IDs and any provider-specific PASS/CHANGES mapping. |
| `review.operations.read`, `publish` | Current review evidence and result publication bindings. For CI, publish may be omitted when CI publishes its own results. |
| `review.external.provider`, `identifiers` | Hybrid mode's external agent/provider, priority scope and terminal verdict mapping. |
| `review.external.operations.read`, `trigger` | External run/findings reads and the actual PR comment or tool that requests review; no arbitrary pipeline steps. |
| `review.external.poll_interval_seconds`, `timeout_seconds` | Positive polling cadence and bounded wait; timeout is a blocker, not an approval. |
| `pr.provider`, `identifiers` | PR provider, repository, base and provider-specific IDs. `base: from_remote_default` resolves the actual remote default unless repo instructions override it. |
| `pr.operations.read`, `update`, `ready` | PR evidence, metadata/finalization update and ready/status-transition bindings. Creation/preparation uses Develop's `pr` skill/command. |

For existing version-1 profiles, omitted new settings preserve the original
contract: `state.provider: work_items`, `execution.concurrent_tasks: false`,
`repository.scope: current_checkout`, `repository.worktree: never`, and no
fallback OpenSpec store. These are documented compatibility defaults, not
permission to replace an explicitly configured but unavailable provider.
The example selects the intended local-then-CI flow, with `when_parallel`
worktrees. Its external check IDs and ranking policy must be filled on the machine;
an empty required-review-check set is not an approval. Existing explicit review
providers are not silently rewritten during installation or update.

Skill/command roles: Explore needs `requirements`, `investigate`, `propose`,
`summary`, `spec_review`, `revise`; Develop needs `apply`, `pr`, `verify`; enabled
Review needs `review`; Owner Review needs `sync`, `archive`. A role is bound in
either `skills` or `commands`, not both. The sync binding may explicitly name the
inline workflow furnished by the installed archive skill. Do not manufacture a
missing skill or CLI command from its name.

Identifiers are opaque provider config. `from_git_origin` resolves the current
repository from its actual Git remote, without assuming a host or path. Bind
documented command placeholders (`repo`, `item`, `item_number`, `slug`, `change`,
`pr`, `head`) from resolved current evidence. `{item}` means the canonical provider
key (e.g. a Jira issue key), not arbitrary invocation text. For
`repository.openspec_change_template`, `{item_lower}` is that key lowercased,
`{repository}` is the current repository name, `{service}` is the repository/service
identity established by current project context (falling back to repository name),
and `{slug}` is a short lowercase ASCII kebab-case description of the approved
intent. Treat the template as simple placeholder substitution only; do not evaluate
expressions or item text as code. Quote arguments for the actual shell.
Operation descriptions may explain provider API/CLI invocation and pagination,
but must not encode stage selection, repair, approval or finalization ordering.

## Direct validation before dependent work

- Require a readable UTF-8 YAML mapping, version 1 and nonempty bindings used by
  the requested command. Reject duplicate keys, unresolved required identifiers,
  arbitrary block names, graph/condition/action DSL fields, or conflicting role
  bindings. Never silently take the last duplicate key or ignore a typo.
- Explore, Develop and Owner Review must be enabled. Review enabled requires the
  `skill` or `skill_then_external` provider; hybrid mode also requires external
  read/trigger bindings, verdict mapping and polling limits. Review omitted/disabled
  requires the CI review provider
  with identifiable required checks and terminal verdict mapping.
- Enabled blocks require available model/reasoning pairs. CI review still uses
  Develop's executor; no standalone reviewer model is required when disabled.
- `next` requires candidate access and a nonempty literal prioritization prompt.
  `status` needs evidence reads, not publish/write access. Do not require every
  future dependency just to display status; check each binding when needed.
- CI configuration must identify the actual review check and distinguish pending,
  PASS, CHANGES and infrastructure failure. A missing check cannot default to PASS.
- External review must distinguish those same states using the actual run,
  published findings and current head/base; a completed run alone is not PASS.
  The configured priority scope may be stricter than the external agent's own
  merge-blocking flag, so inspect findings rather than silently ignore lower priorities.
  For `review.external.provider: ci`, require nonempty actual review-check IDs;
  for another provider, validate that provider's real agent/check identifiers.
- If `repository.openspec_change_template` is non-null, require a nonempty string using only the documented placeholders; reject unknown placeholders or expression syntax.
- Require a known receipt provider and checkout policy. Filesystem receipts need
  a readable directory (a new directory may be initialized on a write invocation);
  `status` remains read-only. Receipt edits cannot manufacture approval or check results.
- Keep credentials outside YAML. Null optional IDs do not enable that board or
  cause automatic access/permission changes. Missing provider access is reported;
  never fall back to another provider.

The agent can reliably read this small flat mapping and literal prompt directly.
Use a YAML parser already available locally for syntax checks when useful; v0
ships no helper code or parser dependency. If YAML is materially ambiguous, stop
the affected operation and identify the field instead of guessing.

## Work-machine adaptation

On that machine edit this same active file, preserving the common skill:

- Set the work-item provider to Jira and supply its real site, required scope IDs,
  candidate query, receipt operations and permitted status transitions. A query
  intentionally spanning projects does not need a fixed project/board ID.
- Replace `prioritization_prompt` with the exact work policy.
- Retain Explore/Develop/Owner Review. For external-only CI review, disable Review
  and set `review.provider: ci`. For local-then-external review, enable Review and
  use `skill_then_external` with an actual external read/trigger/verdict binding.
- Choose external or filesystem receipts and serial or concurrent task execution;
  concurrency must not put different tasks into the same writable checkout.
- Bind the work PR provider, tools, base branch and finalization transitions, and
  that machine's available skills/models/OpenSpec executable.
- Set `repository.openspec_change_template` when this machine needs a work-specific
  change naming convention; for example `'{item_lower}-{service}-{slug}'`. Leave it
  null on machines that should keep the proposal skill's native naming.

Do not invent internal Jira/CI values on another machine. Unconfigured required
bindings block that operation. The v0 human merge gate remains in SKILL.md; changing
a provider-specific ready status cannot enable auto-merge.

## Installation

The repository contains factory/SKILL.md, factory/profile.example.yaml,
factory/agents/ and factory/references/, matching the source layout. For a first install, copy this
factory/ folder into the user-global skill directory and initialize profile.yaml
from profile.example.yaml only when profile.yaml is absent.

For updates, extract the ZIP into staging, copy only SKILL.md, agents/ and
references/, and preserve the existing global profile.yaml. Do not extract over
that profile or create a second active file. The machine's edited profile stays
outside version control; the public default contains no credentials or work IDs.
