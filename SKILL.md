---
name: pocket-engineer
description: Guide an explicitly invoked software task through gated ANALYSIS, DESIGN, DEVELOPMENT, TESTING, and RELEASE_READY phases. Use a fresh phase worker, persistent artifacts, and explicit approval after each phase. Use only when the user explicitly invokes pocket-engineer.
---

# Pocket Engineer

Orchestrate a portable gated workflow. Resolve paths, project conventions, tools, and available agent capabilities from the active environment. Never encode machine- or project-specific values in this skill.

## Lifecycle

`ANALYSIS → DESIGN → DEVELOPMENT → TESTING → RELEASE_READY`

Advance only after the matching command:

- `APPROVE ANALYSIS`
- `APPROVE DESIGN`
- `APPROVE DEVELOPMENT`
- `APPROVE TESTING`
- `APPROVE RELEASE`

Also support:

- `REVISE: <feedback>` — revise the current phase.
- `BACK TO <PHASE>` — return to that phase and invalidate its approval and all downstream approvals.
- `ABORT` — stop the workflow without reverting files or repository state.

Informal agreement, silence, or implied consent is not approval.

After presenting a checkpoint, stop. Do not start the next phase before the matching approval arrives.

## Ownership

Keep the main agent as the orchestrator. It owns:

- canonical state and artifact pointers;
- phase transitions and approval handling;
- user-facing questions and checkpoints;
- worker selection, launch, steering, and result validation;
- integration decisions and authorization boundaries.

Run the work of each phase in a phase worker. A phase worker owns:

- reading its phase workflow and listed input artifacts;
- completing safe phase-local work end to end;
- writing one new phase artifact;
- returning a compact result to the orchestrator.

Workers must not update canonical state, approve phases, transition the workflow, expand scope, or communicate with the user directly.

## Phase map

| Phase | Worker workflow | Profile key |
|---|---|---|
| `ANALYSIS` | `phases/analysis.md` | `pocket-analysis` |
| `DESIGN` | `phases/design.md` | `pocket-design` |
| `DEVELOPMENT` | `phases/development.md` | `pocket-development` |
| `TESTING` | `phases/testing.md` | `pocket-testing` |
| `RELEASE_READY` | `phases/release-ready.md` | `pocket-release-ready` |

Treat phase workflows as worker resources. Pass their resolved paths to phase workers instead of copying their contents into the worker prompt.

Before every spawn, inspect the visible `spawn_agent` schema:

- when it supports `agent_type` and the phase profile is available, spawn the phase's profile key as the agent type; the selected custom-agent TOML controls `model` and `model_reasoning_effort`;
- when it has no `agent_type`, use a generic fresh worker, keep the same worker prompt contract, and record that the model is inherited from the main agent.

Do not pass an inline model or claim that a configured profile was applied when the schema cannot select one.

Configure phase models in the canonical `agent-profiles/<profile-key>.toml`. Keep model and reasoning settings there, never in phase files or installed links. Values in a selected custom-agent file take precedence over global subagent defaults and the parent model.

## Canonical state

Follow the active instruction stack's state location and format when defined. Otherwise create one compact `state.md` in a user-writable task location outside the repository when possible, record its path, and keep it out of commits.

Track only:

```markdown
Workflow:
Phase:
Status:
Awaiting:
Agent profile:
Dispatch mode:
Approved artifacts:
Current artifacts:
Decisions:
Open decisions:
Blockers:
Accepted risks:
Evidence:
Work items:
Changed files:
Repository:
Next:
```

Keep approved decisions with their invalidation conditions, artifact and evidence paths, work-item status, repository identity, and the next action sufficient for resume without chat history.

Do not store phase contents, old artifact contents, discussion history, worker reasoning, raw logs, or full command output in canonical state.

The orchestrator is the only writer of canonical state.

On resume or after automatic compaction, audit the state path, current phase, awaited command, approved artifact paths, branch, HEAD, worktree, changed files, blockers, accepted risks, and next action before continuing.

Material drift returns the workflow to the earliest affected phase after the user confirms the corresponding `BACK TO <PHASE>`.

## Phase artifacts

Store phase outputs beside canonical state under `outputs/`.

Use append-only filenames:

```text
analysis-v001.md
design-v001.md
development-v001.md
testing-v001.md
release-ready-v001.md
```

For every new phase result, choose the next unused version for that phase. Never overwrite, move, or delete an existing phase artifact. An approved artifact is immutable. Keep old candidates and invalidated approvals in place; canonical state identifies the current and approved paths.

## Starting a phase

On first entry into a phase, start a fresh phase worker with no inherited conversation turns when supported.

Pass only:

- the phase ID;
- the resolved path to the phase workflow;
- paths to relevant approved upstream artifacts;
- the repository path and current branch/worktree facts;
- current user decisions or `REVISE` feedback when applicable;
- allowed actions and write boundaries;
- the exact new output path.

Relevant upstream artifacts are:

- `ANALYSIS`: task and linked source paths;
- `DESIGN`: approved ANALYSIS;
- `DEVELOPMENT`: approved ANALYSIS and DESIGN;
- `TESTING`: approved ANALYSIS, DESIGN, and DEVELOPMENT;
- `RELEASE_READY`: approved artifacts relevant to release, including TESTING.

Do not pass the full chat, full canonical state, unrelated artifacts, old revisions, or copied file contents.

Use this compact worker prompt shape:

```text
Perform phase: <PHASE>
Read workflow: <absolute phase-workflow path>
Read inputs:
- <absolute relevant artifact path>
Repository: <absolute path and current facts>
Feedback or decisions: <exact text or none>
Allowed actions: <exact authorization and write boundary>
Write a new artifact: <absolute unused output path>

Return:
- Status: SUCCESS or BLOCKED
- Artifact: <path, when created>
- Checkpoint: <compact summary>
- Evidence: <checks and references>
- Changed files: <paths or none>
- Reason and Next: <required when BLOCKED>
```

For every delegated task, give exact scope, non-scope, input paths, allowed writes, expected evidence, and required checks.

## Worker results

Accept only:

- `SUCCESS` — the phase exit criteria are satisfied and the artifact exists at the assigned new path;
- `BLOCKED` — the phase cannot complete, with a concrete reason and next action.

On `SUCCESS`:

1. Verify that the new artifact exists and no existing artifact was replaced.
2. Record it as the current candidate in canonical state.
3. Present the worker's compact checkpoint and evidence to the user.
4. Request the matching approval or `REVISE`.
5. Stop.

On `BLOCKED`:

- when user input or authority is required, persist the blocker, ask the exact question, then continue the same phase;
- when `Next: BACK TO <PHASE>` is recommended, explain the evidence and wait for the user's explicit command;
- for an external blocker, persist attempted fallbacks and the next actionable step, then stop.

Do not let a worker invalidate approvals or transition the workflow.

## Approval

Accept approval only when it matches the current phase and a successful current artifact is awaiting approval.

On approval:

1. Mark the current artifact approved.
2. Preserve previous artifacts unchanged.
3. Advance canonical state to the next phase.
4. Start that phase in a fresh worker in the same main conversation.

After `APPROVE RELEASE`, mark the workflow complete and provide a concise final summary with artifact paths.

An accepted risk must identify the exact unmet criterion and be explicitly accepted by the user before it can be treated as satisfied.

## REVISE

Accept `REVISE: <feedback>` only while the current phase is awaiting approval.

Keep the current candidate unchanged and select the next unused output version. Send the exact feedback, current candidate path, relevant approved inputs, and new output path to the existing phase worker when it remains available.

If that worker is unavailable or its context is unreliable, start a fresh worker for the same phase with the same paths and feedback. Correctness must not depend on worker-thread continuity.

## BACK TO

On `BACK TO <PHASE>`:

1. Stop or disregard any active worker for the current phase.
2. Invalidate the target phase approval and every downstream approval in canonical state.
3. Preserve every existing artifact unchanged.
4. Do not revert commits, files, branches, or worktrees automatically.
5. Make the target phase current and start a fresh worker with the reason for returning and all still-valid upstream artifact paths.

Reject a forward `BACK TO` target that does not return to the current or an earlier phase.

## Global constraints

- Own the current orchestration step until it succeeds, genuinely blocks, or requires a user decision.
- Investigate available facts before asking the user.
- Separate facts, assumptions, gaps, and decisions.
- Do not modify production code before `APPROVE DESIGN`.
- Do not invent requirements or change approved behavior silently.
- Keep every changed file and behavior mapped to an approved work item.
- Do not deploy to production.
- Create branches, commits, pushes, and pull requests only when already authorized.
- Apply the same lifecycle to small tasks with proportionally smaller artifacts and checkpoints.

Project and global instructions define repository-specific engineering rules. They do not disable this skill's phase order or explicit approval gates.
