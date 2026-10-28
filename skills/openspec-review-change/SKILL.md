---
name: openspec-review-change
description: Review an OpenSpec change before apply. Find material gaps in intent, requirements, design, and tasks. Do not implement or edit unless explicitly asked.
---

# OpenSpec Review Change

Review before implementation. Use the source issue and approved Resolved Intent, when available, as the scope boundary: internally consistent artifacts can still describe the wrong outcome.

Read in order:
1. `proposal.md` — intent and scope.
2. `specs/**/spec.md` — requirements and scenarios.
3. `design.md`, if present — consequential technical decisions.
4. `tasks.md` — work mapped to requirements.

Consult existing base specs only when needed to validate `ADDED` / `MODIFIED` / `REMOVED`. Stop early if the proposal materially misses the intent; reviewing its downstream plan would waste effort.

## Review

Scale depth to impact and reversibility: skim trivial changes; scrutinize data integrity, security, cross-component state, and costly-to-reverse behavior. Report only issues that threaten correctness, scope, acceptance, safe execution, or reasonable implementation cost.

### Intent and scope
- Is there one clear intended outcome with explicit material boundaries and no unrelated work?
- Does the proposal introduce behavior or architecture beyond the requested outcome, even if all artifacts agree?

### Requirements and scenarios
- Each requirement specifies one observable `MUST` / `SHALL` behavior, not an implementation, and has a scenario that actually exercises it.
- Check material supported variants and failure, retry, or duplicate cases where they affect the behavioral contract; do not demand hypothetical coverage.
- Ask: **Would the owner accept a system implementing exactly — and only — these requirements and scenarios?** Identify missing product behavior, especially important cases the owner may not have stated; ask about unresolved choices rather than inventing behavior.
- Check delta operations against existing specs where material.

### Design and complexity
- Does the design resolve consequential ownership, state, failure, and verification decisions without contradicting requirements? Do not demand design detail for routine implementation choices.
- Challenge unjustified compatibility, migration, recovery, versioning, reconciliation, or durable-state machinery. Prefer a single current contract unless coexistence is required; ask whether clean reset or manual recovery is acceptable instead of assuming automation.

### Tasks and verification
- Tasks are ordered, traceable to requirements/design, and free of hidden scope or catch-all steps that conceal material decisions.
- Dependencies, preconditions, and completion checks are clear enough to apply or resume using repository and OpenSpec state.
- Prove behavior at the cheapest authoritative layer; avoid duplicate variant matrices unless layers can independently change the outcome. Require production-equivalent proof where real runtime or external-service semantics matter, and schedule high-risk proof early.
- Separate verification tooling from acceptance when combining them would prevent independent proof.

### Severity

Mark `BLOCKER` only for a concrete failure path that requires changing planning artifacts before safe implementation or verification: a broken primary/acceptance path, contradictory contracts or approved decisions, an unresolved material owner decision, destructive state/identity changes, unsafe ownership, duplicate mutations, or false acceptance.

Do not escalate rare fail-closed outcomes, convenience recovery, extra tests, preferred task order, or routine implementation choices to blockers. Report `WARNING` only for material, realistic, non-blocking risks; omit speculative findings.

Before marking a blocker ask: **Would a competent implementer be unable to finish safely and verify the intended outcome without changing the planning artifacts?** If not, it is not a blocker. Prefer `READY` over defensive hypothetical findings.

## Output

- **Verdict:** `READY` (no material findings), `READY WITH CHANGES` (only non-blocking warnings), or `NOT READY` (at least one blocker; revise before apply).
- **Material findings:** highest impact first, with stable `B1` / `W1` identifiers preserved across review rounds. Format each as `[artifact/section] problem → minimal required correction` and explain its concrete consequence.
- **Owner review:** only unresolved product/scope decisions requiring the owner's judgment; omit if none.

Do not nitpick, expand scope, rewrite artifacts, or implement. If there are no material findings, return `READY` with a short reason.
