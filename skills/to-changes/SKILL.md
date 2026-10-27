---
name: to-changes
description: Propose code-grounded OpenSpec change boundaries and acceptance evidence for a feature, issue, or TDR. Planning only.
---

# To Changes

Choose how to deliver and verify the requested outcome.
Do not assume the work needs splitting.

## Approach

1. Read the source request, approved decisions and applicable project rules.
   Inspect the relevant execution path, consumers and existing checks.
   Resolve technical questions from current sources; distinguish evidence
   from assumptions. Do not invent product decisions.

2. State the outcome, non-goals and observable acceptance criteria.
   For an improvement, identify the baseline and what must improve.
   Reuse existing requirements rather than writing a second specification.

3. Choose cohesive changes with bounded review and verification.
   Split for concrete execution, delivery, risk or verification boundaries,
   not implementation layers or code size alone.
   Keep coupled behavior and its required failure handling together.
   Each change must be verifiable after its declared dependencies.

4. Respect project-defined repository/service execution boundaries.
   A cross-repository milestone consists of coordinated changes, not one
   implicitly atomic change. Identify shared contracts and delivery order.
   Consider an early thin, real end-to-end path when it reduces material
   uncertainty. Defer breadth, not correctness or safety of the included path.

5. Check requirement coverage, hidden dependencies and possible merges.
   Reuse existing verification tools; expose missing proof prerequisites.
   Keep later changes provisional when earlier findings may alter their scope.
   Surface unresolved decisions that materially affect the proposed boundaries.

## Output

- Outcome and non-goals.
- Proposed changes: title, repository/service, delivered behavior, scope
  boundary, dependencies and evidence-backed reason for each separation.
- Acceptance map: criterion → responsible changes → expected result,
  proof method, prerequisites and when the proof should first run.
- Recommended first step and material unresolved decisions.

One change is valid. Recommend no new change when the outcome already exists.
Do not create issues, files, OpenSpec artifacts or PRs unless explicitly requested.
