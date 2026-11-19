# Machine-local bindings

The only active file is `profile.yaml` beside `SKILL.md`. It is optional and ignored by Git. Without it, resolve the item/provider, repository, base and tools from current project context; do not initialize a file just to run Factory. The example is a GitHub binding, not a requirement to use GitHub on work projects.

Version 2 removes per-stage models, executor routing and mandatory skill chains. Select the intended GPT-6.2 model in the host. Configuration text cannot change a running model. This file describes bindings; the skill owns the workflow and approvals.

## Fields

| Field | Meaning |
| --- | --- |
| `version` | Required `2` when a profile is present. See migration below for `1`. |
| `state.provider` | `work_items` (default) uses existing item/PR records; `filesystem` uses one Markdown receipt per item in `state.directory`. |
| `state.directory` | Required for filesystem receipts. Resolve `~` against the real home directory. `status` never creates it or a receipt. |
| `work_items.provider`, `identifiers` | Existing service and its real project/query/status identifiers. Infer only unambiguous values from the item or project; do not invent private IDs. |
| `work_items.operations` | Optional `read`, `candidates`, `active`, `record` tool/command bindings. Otherwise use the provider's existing capabilities. `active` reads the selected receipt store, including filesystem records when configured. |
| `work_items.transitions` | Optional named provider actions (`started`, `suspended`, `ready_to_merge`); no automatic issue closure or merge. |
| `repository.context` | Additional relevant project paths, loaded when needed; applicable repository instructions always apply. |
| `repository.openspec_command` | Installed executable/path, subject to project CLI conventions. |
| `repository.openspec_store` | Registered fallback store for a project without local OpenSpec, or the shared store for a multi-repository item. Preserve the chosen canonical store/change on resume. |
| `repository.openspec_change_template` | Optional simple template with `{item}`, `{item_lower}`, `{repository}`, `{service}`, `{slug}`; null preserves native OpenSpec naming. |
| `repository.branch_template` | Optional template using the same placeholders plus `{item_number}` when the provider has a numeric ID. Project rules take precedence. |
| `prioritization_prompt` | Exact ranking policy, stored as a YAML literal block (`|`). Only `next` requires it. Current item data stays separate from the policy. |
| `review.source` | `independent` (default): one fresh reviewer. `external`: an explicitly bound independent service supplies the review instead. Required project gates apply in both cases. |
| `review.skill` | Optional local review skill, e.g. explicitly selected `ensemble-code-review`; null uses the Factory review contract directly. Used only with `source: independent`. |
| `review.required_checks` | Additional required CI check names/IDs, combined with project requirements; an empty list never disables project gates. |
| `review.external` | Required with `source: external`; also usable with `independent` for an additional required external gate. Bind the provider, real identifiers, `operations.read` and any explicit `operations.trigger`. Map current findings to pending/PASS/CHANGES/failure and retain the configured priority scope. Optional polling/timeout values must be positive. |
| `pr.provider`, `identifiers` | PR provider and per-repository remote/base. `from_git_origin` and `from_remote_default` resolve against each target checkout. |
| `pr.operations` | Optional `read`, `update`, `ready` bindings. PR creation still uses `create-pr`. |

Omitted optional values use the defaults above and the skill's repository discovery. A supplied binding is authoritative: unavailable access is a blocker for that operation, not permission to switch providers. Read only dependencies needed now; `status` needs no write access. With filesystem receipts, `record` writes the local file and does not authorize work-item comments.

Read UTF-8 YAML directly; an installed parser may help but is not a runtime dependency. Reject duplicate keys, unknown top-level/role fields, unsupported versions and conflicting bindings. Reject `review.skill` with `source: external`. External review requires identifiable checks/agents and published findings tied to the current candidate/base; an empty/missing set is not PASS. Reuse an applicable running review, respect the provider's polling guidance and use a bounded wait. A timeout, access error or failed run stays a blocker.

Templates are substitution, never executable expressions. `{item}` is the canonical provider key, `{item_lower}` its lowercase form, `{repository}` the starting repository name and `{service}` its established service identity (falling back to that repository name). `{slug}` is a short ASCII kebab-case description. Reject unknown/unresolved placeholders and quote resolved arguments for the actual shell.

## Migrating an existing version-1 profile

Do not silently run a v1 profile as v2 or overwrite it during an update. Read-only `status` may use its existing evidence-read bindings. Before the next write invocation, show a proposed v2 mapping and any changed review/concurrency policy; the owner must choose those policy changes. Existing authorized job records and accepted changes remain valid; migration does not restart them.

1. Keep `state`, service providers/identifiers, applicable read/record/status operations, OpenSpec store/path/naming, branch convention, exact prioritization policy and PR bindings. Replace placeholder prose with actual bindings only where the local environment requires them; never publish private IDs or credentials.
2. Remove `blocks` and its model/reasoning/escalation/skill-chain settings. Choose the real model in the host. The native OpenSpec proposal/apply/archive skills and `create-pr` remain available without stage-specific configuration.
3. Replace `review` deliberately:
   - Old `skill`: choose `source: independent`; retain the prior skill only if still wanted. The new baseline leaves `skill: null`.
   - Old `ci`: choose `source: external`; move its provider/identifiers/read/trigger/verdict bindings into `review.external`.
   - Old `skill_then_external`: preserve the external review binding. Use `source: external` if that service satisfies the whole independent review contract. If a local review is also required, choose `source: independent` and retain the external requirement through the real repository-required checks or `review.required_checks`; keep the necessary trigger/findings binding in `review.external`. Do not drop the external gate just to match the example.
4. `execution.concurrent_tasks` and `repository.scope/worktree` no longer control an orchestrator. The skill handles one named item and isolates occupied checkouts. Carry any required single-active-job policy into project instructions before removing it; do not silently relax it. New multi-repository writes still require explicit scope.
5. Set `version: 2` only after the mapping is complete. Save the reviewed local profile where the old one lived. The tracked example and Git update never replace it.

For work projects, retain the real Jira/PR/CI bindings and permitted transitions. Missing work access is a concrete blocker; do not substitute the GitHub example or fabricate a successful review.
