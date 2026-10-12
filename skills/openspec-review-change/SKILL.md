---
name: openspec-review-change
description: Review an OpenSpec change before apply. Find material problems in intent, requirements, design, and task decomposition. Do not implement or edit unless explicitly asked.
---

# OpenSpec Review Change

Review the requested OpenSpec change before implementation.

Before reviewing the change, read the source issue / approved Resolved Intent when available.
Treat it as the primary scope boundary.

Flag planning machinery that materially exceeds the requested outcome even if proposal/spec/design are internally consistent with each other.

Read, in order:

1. `proposal.md`
2. `specs/**/spec.md`
3. `design.md`, if present
4. `tasks.md`
5. Existing base specs only when needed to validate `ADDED` / `MODIFIED` / `REMOVED`.

## Review

Check only for issues that could cause wrong implementation, scope creep, weak acceptance, blocked execution, or wasted apply work.

### Severity calibration

Use `BLOCKER` only when the artifacts must change before a reasonable implementer can safely and correctly complete or verify the requested change. A blocker needs a concrete failure path and at least one of these consequences:

- the primary supported or acceptance path cannot work;
- requirements/design materially contradict each other or an accepted decision;
- an important product or architecture decision is missing and cannot be inferred safely;
- the specified behavior can credibly cause duplicate mutation, identity corruption, data loss, unsafe ownership, or a false acceptance verdict.

Do not classify an issue as `BLOCKER` merely because it describes:

- a narrow timing window or rare crash with a conservative fail-closed/blocked outcome;
- missing convenience recovery or operator ergonomics;
- a preferred task order, extra test, audit hardening, or clearer wording;
- an implementation detail that can be resolved within the stated requirements and invariants.

An edge case may still be a blocker when its consequence is destructive or violates a core safety invariant and the design does not contain it. Otherwise omit it or use `WARNING` only when the risk is material to realistic apply work.

Before emitting a blocker, ask: **Would a competent implementer be unable to finish safely and verify the intended outcome without changing the planning artifacts?** If the answer is no, it is not a blocker. Prefer `READY` over defensive hypothetical findings.

### Intent and scope
- The change has one clear intent.
- Scope matches the requested outcome and does not contain unrelated work.
- Important boundaries or out-of-scope behavior are explicit where ambiguity would matter.

### Complexity and migration gate

- Challenge compatibility, migration, recovery, versioning, reconciliation, or durable-state machinery that is not explicitly required by the source intent.
- If such machinery is comparable in complexity to the feature itself, surface it as a material finding and ask whether a simpler operational boundary is acceptable (for example clean reset or one-time manual migration).
- Prefer one current contract over coexistence of old and new contracts unless backward compatibility is an explicit requirement.
- Do not require automatic recovery for states that the owner is willing to resolve operationally.

### Requirements
- Each requirement defines one observable behavior with `MUST` / `SHALL`.
- Requirements describe behavior, not implementation.
- Scenarios actually exercise the requirement and cover important edge, error, retry, duplicate, or failure cases where relevant.
- `ADDED` / `MODIFIED` / `REMOVED` are correct relative to existing specs.

### Design
- The design is sufficient to implement the requirements without inventing important decisions during apply.
- Important failure behavior and verification strategy are defined where needed.
- Design and specs do not contradict each other.

### Tasks
- Tasks are traceable to the approved requirements/design and contain no hidden scope.
- Each task block is a coherent, independently executable work packet suitable for a fresh subagent.
- Each block has a clear verification boundary and enough context/preconditions to execute without rediscovering the design.
- Prefer small blocks (~2–4 tasks when practical).
- Split verification-tooling development from production acceptance when combining them would make the block non-independent or hard to verify.

### Verification economy

- Each behavior should be proven at the cheapest authoritative layer.
- Do not duplicate the same variant matrix through multiple layers unless each layer can independently corrupt that behavior.
- Use focused unit/integration tests for deterministic Core/config/wire behavior and production-equivalent runtime proof only for mechanics that depend on the real GameServer.
- Move the highest-risk production proof early enough that failure would not invalidate a large amount of later implementation.

## Output

Return:

1. **Verdict:** `READY` / `READY WITH CHANGES` / `NOT READY`
2. **Material findings**, highest impact first
3. **Owner review** — only product/scope decisions that require the project owner's judgment
4. **Execution batches** — suggest 2–3 apply-with-subagents batches using complete top-level task blocks

For findings:
- use stable identifiers `B1`, `B2`, ... for blockers and `W1`, `W2`, ... for warnings;
- format each as:
  `[artifact/section] problem → minimal required correction`;
- preserve identifiers in follow-up review rounds.

Each execution batch must:
- contain complete top-level task blocks;
- end in a stable verified state;
- be restartable from repo + OpenSpec state without previous chat context.

Do not:
- nitpick wording or formatting;
- propose unrelated improvements;
- rewrite the artifacts;
- implement anything;
- report speculative issues without a concrete failure mode.

If there are no material findings, return `READY` with a short reason.