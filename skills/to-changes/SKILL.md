---
name: to-changes
description: Plan code-grounded OpenSpec changes and acceptance for a feature, issue or TDR.
---

# To Changes

Read the request, approved decisions, project rules and relevant code/tests.
Do not invent product decisions.

## Plan
- Group by behavior, not layers or code size alone. Keep required failure handling together.
- Each change must be reviewable and verifiable after its dependencies.
- Split for concrete delivery, risk or project execution boundaries. Coordinate cross-repository changes through explicit contracts and dependencies.
- Consider a thin real end-to-end path when it reduces uncertainty. Defer breadth, not correctness or safety.
- Check coverage, dependencies and possible merges. One change, or no new work, is valid. Keep uncertain later changes provisional.

## Return
- Outcome, non-goals and baseline for improvements.
- Changes: scope, repository/service, behavior, dependencies and concrete reason for separation.
- Acceptance: criterion → responsible changes → expected result → proof, prerequisites and when to run.
- First step and unresolved decisions.

Planning only. Do not edit files or create issues, changes or PRs unless explicitly requested.
