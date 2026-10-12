---
name: openspec-apply-with-subagents
description: Execute an OpenSpec change block-by-block using fresh scoped subagents.
---

Execute an OpenSpec change through fresh subagents with minimal duplicated context.

## Input

- OpenSpec change name.
- Optional task blocks to execute.
- Optional `--no-telemetry`.

## Roles

- `openspec-block-developer` — implementation, diagnosis, repair, recovery, final verification.
- `openspec-block-reviewer` — all code-review rounds.

## Runtime Binding

Use the runtime-native profiles named in `Roles`. Models and provider-specific reasoning belong to those profiles, not this skill. A missing profile, model, required skill, or lifecycle capability is a setup blocker; never silently substitute a generic agent, a paid model, or direct implementation by the orchestrator.

- **Codex:** keep the native named-agent launch/send/wait/resume lifecycle. Start fresh agents with `fork_turns="none"` when that parameter is exposed by the runtime. Retain and reuse each returned agent handle.
- When waiting for a child, use the longest runtime-supported wait interval. A wait timeout is not new workflow evidence: continue waiting unless the child returned a result, failed, or exceeded a material expected bound.
- **OpenCode:** launch through the native `task` tool with `subagent_type` set to the exact role name, a short `description`, and the scoped `prompt`. Omit `task_id` for a fresh cycle/role; retain the child-session handle returned in the tool output/metadata as that role's `task_id`. Every continuation uses the same `subagent_type` and saved `task_id`. Do not pass Codex-only `fork_turns`, `model`, or reasoning arguments to `task`.
- For OpenCode, use the default foreground execution; do not request background mode or invent a separate Codex-style wait call. Proceed from the completed tool result. If the runtime reports a running task instead, follow its exposed completion mechanism without polling or duplicating work.
- Keep separate developer/reviewer handles per execution block or fresh repair cycle, including in pause handoffs. If a resume returns a different handle, treat it as a replacement and apply the existing recovery rules; do not claim continuity. Retiring an OpenCode pair means never reusing its handles, not deleting its session history.
- Ask each worker to load its required skill using the active runtime's skill mechanism. In OpenCode this is `skill({name: "..."})`; `$skill` and `/skill` text inside a delegated prompt is not a substitute for loading it. Pass only scoped context, not a copy of the parent conversation.

## Cycle Model

A cycle is either:

- `execution` — one top-level execution block: a level-2 `tasks.md` heading
  matching `## <integer>. <title>` and ALL checkbox tasks contained under it
  until the next level-2 heading. Checkbox IDs such as `1.1`, `1.2`, `1.3` are tasks inside execution block `1`; they are never separate execution cycles unless the user explicitly requests a narrower ad-hoc scope.
- `repair` — defects that cannot be attributed to one existing block owner.

Each execution cycle starts with one fresh `openspec-block-developer`; its first review starts with one fresh `openspec-block-reviewer`.

Keep the pair sticky while implementing and reviewing the block.

After the block completes, keep its developer/reviewer handles resumable until the current apply batch ends, but only for corrections attributable to that block's original contract.

Resume the existing block owner when:
- a defect violates a requirement or invariant originally owned by that block; or
- the defect was introduced by that block's implementation.

Before resuming a completed block owner, identify the exact original task/spec requirement or changed behavior that owns the defect.

Do NOT send a retained owner:
- new feature scope;
- later-block requirements;
- adjacent cleanup;
- newly discovered architecture work not required by its original contract.

Start a fresh repair cycle only when:
- the defect genuinely spans completed blocks with no single clear owner;
- fixing it requires a new cross-block architecture/contract;
- it is newly added scope or a new requirement; or
- the original owner cannot continue.

A new failure mode, subsystem, runtime observation, or verification phase alone does not justify a new owner.

If an active agent must be replaced, preserve the scoped context, repository/review state, completed checks and exact next action, then continue the same logical cycle.

## Communication

Translate agent state into brief user-facing progress: what changed, why it matters, blocker/risk if any, and what happens next.
Prefer observable behavior over internal jargon and do not narrate routine tool calls.

## Scoped Context

Prepare the smallest sufficient context for the current cycle:

- exact task text or repair goals;
- relevant design/spec requirements;
- required dependencies or accepted evidence from completed work.

Preserve implementation-critical contracts, fields, constants, identities and invariants exactly. Exclude unrelated planning content and repository discovery.

For a repair cycle, also include the failure evidence and accepted prior verification. Repair only the reported defects; reopen completed scope only when required to fix or verify them.

## Workflow

1. Load the change once: proposal, specs, design, tasks, and applicable OpenSpec apply instructions.

2. Parse execution blocks from level-2 `tasks.md` headings (`## 1.`, `## 2.`, ...).

Assign all pending checkbox tasks under one heading to the SAME execution cycle and developer. Never create separate cycles from individual task IDs such as `1.1`, `1.2`, or `1.3`.

3. Prepare the cycle's scoped context according to `Scoped Context`.

4. Launch a fresh subagent `openspec-block-developer` for the cycle.

Use the fresh-agent operation from `Runtime Binding`.

Give it:

```text
Load and follow the `openspec-apply-change` skill for change <change>.

Cycle: <execution | repair>
Scope: <task IDs | repair goals>
Telemetry: <enabled | disabled>

Invocation-specific context override:

The orchestrator has already read the complete OpenSpec planning context and
prepared the scoped execution context below.

Do NOT reread proposal/spec/design/tasks or OpenSpec `contextFiles` as normal
startup work, even if `openspec-apply-change` normally instructs you to do so.

Use `<scoped-context>` as the authoritative planning input for this delegated scope.

If it is materially insufficient or contradictory:
1. state the exact missing or contradictory fact;
2. read only the specific original artifact/section needed to resolve it;
3. record `planning_fallback: yes` and why.

Do not fall back to rereading the complete change.

<scoped-context>
...
</scoped-context>
```

5. When the developer returns `READY_FOR_CODE_REVIEW`, launch one fresh `openspec-block-reviewer` using `Runtime Binding`.

Give it:
```
   Load and follow the `code-review-skill` skill.

   Change: <change>
   Cycle: <execution | repair>
   Scope: <task IDs | repair goals>

   <scoped-context>
   ...
   </scoped-context>
```

   If material findings remain:

   1. Send all open findings unchanged, especially preserving their IDs and fix contracts, to the same developer.
   2. Send its dispositions and updated diff to the same reviewer; the reviewer owns finding closure.
   3. Repeat for at most 3 review rounds.

   After 3 unsuccessful rounds, stop and surface the remaining finding IDs and required outcomes.

   Do not reopen a closed/disputed finding unless a later change invalidates its resolution.

Maintain an explicit material-finding ledger per execution block: `finding ID → OPEN | CLOSED | ACCEPTED_DISPUTE`.

A material finding remains `OPEN` until the same reviewer explicitly closes or accepts dispute for that ID. New work, new review deltas, user input, repair, or context compaction do not clear existing findings.

Never complete a block while its ledger contains an `OPEN` finding.

6. After `REVIEW_PASS`, resume the same developer for final verification.

   If final verification causes a material code change, let the same developer fix it
   with focused checks, then resume the same reviewer for a targeted review of the
   post-pass delta. Allow at most 3 targeted review rounds.

7. Wait for the active developer to finish the cycle.

   If the active agent raises an ambiguity or required decision:
   - resolve it from the existing spec, design, repository state, or project rules when possible;
   - ask the user only for a genuine product/design decision;
   - gather any additional technical facts through the same active agent;
   - return the resolved decision to that agent and resume the cycle.

   If telemetry is enabled, retain its session reflection according to `Telemetry`.

8. When an execution block completes or is handed to the user for external/manual verification:
   - preserve its accepted evidence and review state;
   - keep its developer/reviewer handles resumable for corrections owned by that block's original contract;
   - continue with the next selected block.

If later evidence exposes a defect, apply the ownership test from `Cycle Model` before deciding whether to resume an existing block owner or start a fresh repair cycle.
If the defect returns to an existing block owner, resume that developer for the
focused fix and invalidated checks, then resume the SAME retained reviewer for
a targeted review of the resulting delta before accepting the block again.

9. When all selected blocks in the current apply batch are complete:
   - retire all retained developer/reviewer pairs;
   - emit `Workflow Telemetry` when enabled;
   - finish.

## Pause and Resume

On pause:

1. Do not start new work; let any non-interruptible check reach a safe stop.
2. Ask the active agent for a concise handoff: cycle/scope, phase, completed work/checks, review state, repository state, exact next action, and intentionally running services/cleanup.
3. Preserve the handoff and record the pause; paused time is excluded from active telemetry.
4. Return `WORKFLOW_PAUSED`.

On resume:

1. Restore the handoff and validate repository/OpenSpec state only as needed.
2. Continue the same logical cycle from its recorded next action.
3. Reuse the previous active agent when possible; otherwise launch a fresh replacement with the saved context/state.
4. Do not repeat accepted work without concrete invalidation.

## Telemetry

Enabled by default; `--no-telemetry` disables it.

When enabled, maintain one orchestrator-owned execution ledger. Record events when they happen; prefer runtime metadata and never infer timings from conversation text.

### Record

For each cycle and agent:
- cycle type/scope and start/end;
- custom agent, configured/runtime model and reasoning when exposed;
- agent start/end/duration/status and spawn reason;
- replacements, recoveries, and incomplete handoffs;
- `READY_FOR_CODE_REVIEW`, review rounds, material finding counts/dispositions, `REVIEW_PASS`;
- final-verification resume;
- material expensive checks and reruns;
- pause/resume and user-wait intervals;
- cross-cycle/post-cycle follow-up;
- scoped execution packet: task/block IDs, included spec requirements, included design decisions, dependency/evidence references, and approximate size;
- planning fallback: whether the developer had to read original planning artifacts, exact missing fact, and exact artifact/section read.

Treat unexpected replacement, incomplete handoff, recovery agent, model mismatch, or work sent to a retired thread as a workflow deviation.

Retain the developer's `## Session Reflection` when returned. Do not reopen otherwise completed work solely to obtain missing telemetry; mark it unavailable unless material unexplained rework requires clarification.

### Workflow Telemetry

Report:

**Timing**
- active workflow time; paused/user-wait separately;
- per-cycle developer/reviewer/final-verification time when available;
- 3 slowest phases and measured checks.

**Review**
- rounds, implementation returns and material findings per cycle;
- targeted post-verification rounds;
- unusually high review churn.

**Lifecycle / rework**
- replacements, incomplete completions and recovery agents;
- cross-cycle leakage and post-cycle follow-up;
- expensive reruns and causes;
- total spawns and cycles with replacement owners;
- assignments to retired threads — expected `0`.

**Quality**
- defects found by review;
- defects escaping to final/runtime verification;
- planning fallback / extra discovery;
- 3 strongest bottlenecks and concrete prevention.

**Models**
- custom agent;
- configured model/reasoning;
- runtime-reported model/reasoning when available;
- mismatches.

Telemetry is part of workflow completion when enabled. Do not emit final completion before this report; mark unavailable metrics explicitly rather than reconstructing low-value data.

## Guardrails

- The orchestrator never implements code or runs developer-owned verification.
- The orchestrator does not independently investigate implementation or runtime behavior. Technical code/runtime diagnosis belongs to the retained block developer. The orchestrator may inspect only planning, workflow, repository status, and session state needed to scope or route work.
- Never send new work to a retired agent thread.
- Never pass full planning artifacts when scoped context is sufficient.
- Never repeat accepted expensive verification without concrete invalidation.
- Do not yield while executable workflow work remains unless blocked on a genuine user decision or explicitly paused.
- Never create a topical repair/recovery/verification developer when an existing block owner clearly owns the defect under its original task/spec contract.