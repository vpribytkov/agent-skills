---
name: to-changes
description: Plan code-grounded OpenSpec changes and acceptance for a feature, issue or TDR.
---

# To Changes

The user has a feature description, issue or technical design and needs an implementation breakdown.
Propose a sequence of OpenSpec changes: scoped units of implementation and verification that together deliver the requested feature.

## Plan
1. Read the source request, approved decisions, project rules and relevant code/tests. Identify required behavior and acceptance criteria, what already works and what remains to implement. Flag unresolved product decisions instead of inventing them.
2. Group the remaining implementation work into changes by delivered behavior, not technical layers or code size alone. Keep required failure handling with the behavior it protects.
3. Make each change reviewable and verifiable after its dependencies. Split for concrete delivery, risk or project execution boundaries; specify shared contracts and delivery order between repositories.
4. Order changes to reduce uncertainty early. Consider a narrow real end-to-end path when it reduces integration risk; defer supported variants, not required correctness or safety.
5. Map every acceptance criterion to responsible changes and sufficient proof, reusing existing checks. Identify missing prerequisites and when to run each check.
6. Check coverage and merge unnecessary splits. One change or no new work is valid. Keep uncertain later changes provisional.

## Return
- The requested result for the whole feature, non-goals and baseline for improvements.
- Changes: title, scope, repository/service, behavior, dependencies and concrete reason for separation.
- Acceptance: criterion → responsible changes → expected result → proof, prerequisites and when to run.
- First step and unresolved decisions.

Planning only. Do not edit files or create issues, changes or PRs unless explicitly requested.
