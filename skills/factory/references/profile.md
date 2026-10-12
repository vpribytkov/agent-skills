# Machine-local profile

Read the one `profile.yaml` beside the installed SKILL.md. The source and ZIP use
that same filename for public home defaults; the installed copy is machine-local.
Do not auto-select a profile by repo, hostname, environment or command argument.

## Fields

| Field | Meaning |
| --- | --- |
| `version` | Schema version; v0 implementation accepts `1`. |
| `work_items.provider` | Installed work-item provider, e.g. GitHub or Jira. |
| `work_items.identifiers` | Provider-owned scope, repository, board/project and status-field/option IDs. |
| `work_items.operations.read` | Tool/command binding to read one item and linked evidence. |
| `work_items.operations.candidates` | Read operation and scope/pagination for current candidates. |
| `work_items.operations.active` | Read operation covering unfinished jobs in the configured provider scope. |
| `work_items.operations.record` | Provider binding to persist necessary receipts and links. |
| `work_items.transitions` | Provider-specific targets/actions for started, suspended, ready_to_merge and merged. No implied timing. |
| `repository.context` | Additional current project context paths; missing optional docs are reported/skipped. AGENTS.md always applies independently. |
| `repository.openspec_command` | Machine's OpenSpec executable/path; preserve repository CLI constraints. |
| `repository.branch_template` | Project branch convention; current repository instructions take precedence. |
| `prioritization_prompt` | Exact ranking policy; use a YAML literal block scalar rather than a folded scalar. |
| `blocks.<name>.enabled` | Enables a known block; only Review can be omitted in v0. |
| `blocks.<name>.model`, `reasoning` | Main-chat settings for Explore/Owner Review; dispatched executor settings for Develop/Review. |
| `blocks.<name>.skills` | Installed skill bindings for the roles used by that block. |
| `blocks.<name>.commands` | Alternative command/tool bindings for those same roles. |
| `blocks.develop.escalation` | Optional model, reasoning and technical escalation criterion. |
| `review.provider` | `skill` for independent Review, `ci` for review/repair inside Develop. |
| `review.identifiers` | Relevant review-agent/check IDs and any provider-specific PASS/CHANGES mapping. |
| `review.operations.read`, `publish` | Current review evidence and result publication bindings. For CI, publish may be omitted when CI publishes its own results. |
| `pr.provider`, `identifiers` | PR provider, repository, base and provider-specific IDs. |
| `pr.operations.read`, `update`, `ready` | PR evidence, metadata/finalization update and ready/status-transition bindings. Creation/preparation uses Develop's `pr` skill/command. |

Skill/command roles: Explore needs `requirements`, `investigate`, `propose`,
`summary`, `spec_review`, `revise`; Develop needs `apply`, `pr`, `verify`; enabled
Review needs `review`; Owner Review needs `sync`, `archive`. A role is bound in
either `skills` or `commands`, not both. The sync binding may explicitly name the
inline workflow furnished by the installed archive skill. Do not manufacture a
missing skill or CLI command from its name.

Identifiers are opaque provider config. `from_git_origin` resolves the current
repository from its actual Git remote, without assuming a host or path. Bind
documented command placeholders (`repo`, `item`, `item_number`, `slug`, `change`,
`pr`, `head`) from resolved current evidence. Quote arguments for the actual shell;
never evaluate item text as code or use a generic template/expression engine.
Operation descriptions may explain provider API/CLI invocation and pagination,
but must not encode stage selection, repair, approval or finalization ordering.

## Direct validation before dependent work

- Require a readable UTF-8 YAML mapping, version 1 and nonempty bindings used by
  the requested command. Reject duplicate keys, unresolved required identifiers,
  arbitrary block names, graph/condition/action DSL fields, or conflicting role
  bindings. Never silently take the last duplicate key or ignore a typo.
- Explore, Develop and Owner Review must be enabled. Review enabled requires the
  skill review provider; Review omitted/disabled requires the CI review provider
  with identifiable required checks and terminal verdict mapping.
- Enabled blocks require available model/reasoning pairs. CI review still uses
  Develop's executor; no standalone reviewer model is required when disabled.
- `next` requires candidate access and a nonempty literal prioritization prompt.
  `status` needs evidence reads, not publish/write access. Do not require every
  future dependency just to display status; check each binding when needed.
- CI configuration must identify the actual review check and distinguish pending,
  PASS, CHANGES and infrastructure failure. A missing check cannot default to PASS.
- Keep credentials outside YAML. Null optional IDs do not enable that board or
  cause automatic access/permission changes. Missing provider access is reported;
  never fall back to another provider.

The agent can reliably read this small flat mapping and literal prompt directly.
Use a YAML parser already available locally for syntax checks when useful; v0
ships no helper code or parser dependency. If YAML is materially ambiguous, stop
the affected operation and identify the field instead of guessing.

## Work-machine adaptation

On that machine edit this same active file, preserving the common skill:

- Set the work-item provider to Jira and supply its real site, project/board IDs,
  candidate query, active-job query, read/receipt operations and status transitions.
- Replace `prioritization_prompt` with the exact work policy.
- Retain Explore/Develop/Owner Review; disable or omit Review.
- Set `review.provider: ci`, identify the existing review check and configure its
  evidence read and verdict mapping. Its repairs use the common Develop loop.
- Bind the work PR provider, tools, base branch and finalization transitions, and
  that machine's available skills/models/OpenSpec executable.

Do not invent internal Jira/CI values on another machine. Unconfigured required
bindings block that operation. The v0 human merge gate remains in SKILL.md; changing
a provider-specific ready status cannot enable auto-merge.

## Installation

The package contains factory/SKILL.md, factory/profile.yaml, factory/agents/ and
factory/references/, matching the source layout. For a first install, copy this
factory/ folder into the user-global skill directory. Its profile.yaml is ready
to edit on that machine; no rename or absent example file is required.

For updates, extract the ZIP into staging, copy only SKILL.md, agents/ and
references/, and preserve the existing global profile.yaml. Do not extract over
that profile or create a second active file. The machine's edited profile stays
outside the repository; the public default contains no credentials or work IDs.
