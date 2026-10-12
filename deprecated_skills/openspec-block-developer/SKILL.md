---
name: openspec-block-developer
description: Scoped implementation and repair behavior for OpenSpec execution blocks.
---

# OpenSpec Block Developer

## General Flow

The delegated scope is either task IDs for an execution cycle or repair goals for a repair cycle. Wherever these instructions refer to assigned tasks, requirements, or block scope, apply them to the current delegated scope.

Report only meaningful milestones, blockers, review and verification outcomes; explain behavior and evidence plainly and do not narrate routine tool calls.

Use the supplied scoped context instead of rereading OpenSpec planning artifacts.
Fall back to originals only when the scoped context is insufficient, contradictory, or exposes a material design ambiguity.
All other `openspec-apply-change` instructions remain in effect.

Any direct read, search, or lookup of the change's original proposal, design, tasks, or specs for planning information counts as `planning_fallback: yes`, even if it only confirms existing context or does not change the implementation.

Record the first concrete reason for that fallback and the exact artifact/section consulted. Reading runtime apply instructions or repository code does not count.

Before editing, batch discovery across the whole delegated seam: identify and read the relevant production code, call sites, tests, and contracts together. Avoid repeated rereads unless new evidence changes the working hypothesis.
Treat Dockerized verification as expensive: batch coherent edits, then run the narrowest relevant Docker suite once. Do not rerun unchanged harnesses after every small edit; defer broad Docker verification to the final gate.

For long-running commands, use the longest practical runtime-supported wait interval.
Do not poll builds, tests, Docker startup, or verification at short intervals.
A timeout with no new failure evidence means continue waiting; it does not justify
extra status probes or unrelated diagnosis.

For runtime diagnosis, gather one bounded coherent snapshot before reasoning when the required probes are already known. Batch independent exact DB/HTTP/log checks whose combined output is predictably small.

Do not serially query related runtime state one field/table/endpoint at a time unless an intermediate result genuinely determines the next probe.

Follow existing system/domain structure and vocabulary; OpenSpec change IDs, task numbers and milestone/acceptance labels are planning metadata, never production concepts.

## Pre-review gate

Before `READY_FOR_CODE_REVIEW`:

1. Implement the complete delegated behavior using the required production seam and executable proof; establish RED first when practical.
2. Cover required negative, replay, fencing and sibling cases, not only the first positive path.
3. Run all applicable cheap deterministic checks: format, lint/static analysis, compile/type checks, and focused tests.
4. Audit every delegated requirement to an implementation anchor and executable proof.
5. For every claimed proof, verify that it crosses the production-owned seam that implements the requirement. The proof must fail if the required production call, contract, guard, or state transition is removed or violated. A helper, mapper, fixture, mock, injected boundary, or static/text check that bypasses that seam does not prove the requirement.

Do not return `READY_FOR_CODE_REVIEW` while a required behavior/proof is missing or any required cheap check fails.

Return:
- **Task audit:** requirement → implementation anchor → proof
- **Pre-review checks:** check → result
- **Deferred:** expensive/final verification only

## Session Reflection

When `Telemetry: enabled`, return a concise `## Session Reflection` on cycle completion or true blocker; omit it while paused for review.

Include only material items, max 3 each:

**Workflow inefficiency**
Evidence / Cost / Cause / Prevention / Impact

**Code correction**
- Defect
- Trigger: self-check | code review | final verification | runtime acceptance
- Root cause: REQUIREMENT_GAP | DESIGN_GAP | TASK_GAP | IMPLEMENTATION_ERROR | TEST_GAP | CROSS_COMPONENT_GAP | REPO_CONTEXT_GAP | ACCEPTANCE_ONLY
- Earlier catch point
- Prevention

Finish with:
```
## Telemetry
- `planning_fallback`: `no` only if no original proposal/design/tasks/spec planning artifact was consulted; otherwise `yes` + trigger/reason + exact artifact/section
- `extra_discovery`
- `main_bottleneck`
```

## Review Findings

When resumed with material findings, treat each `Required outcome` as the fix contract and resolve the underlying defect, not only the reported example.

Return one disposition per finding:
- `FIXED` — fix + focused closure evidence
- `DISPUTED` — concrete contract/code evidence
- `BLOCKED` — concrete blocker

Do not return for re-review until every finding has a disposition and every `FIXED` finding has focused verification.

After `REVIEW_PASS`, continue the current cycle:
- run the remaining expensive/final verification required by the delegated scope;
- complete only the delegated task IDs or repair goals;
- commit when the current cycle's completion criteria are satisfied.
