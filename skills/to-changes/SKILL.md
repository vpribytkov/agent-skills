---
name: to-changes
description: "Use when asked to break a feature, issue or technical design into code-grounded OpenSpec changes and acceptance. Optional delivery planning, not required for ordinary implementation."
---

# To Changes

Propose the implementation and verification units needed to deliver the requested feature. Planning only: do not edit files or create issues, OpenSpec artifacts or PRs unless asked. Use the installed native OpenSpec workflow when artifact creation is authorized.

## Plan

1. Read the request, approved decisions, project rules and relevant code/tests. Establish required behavior and acceptance, what already works and what remains. Surface consequential unresolved decisions instead of inventing them.
2. Group work by delivered behavior, keeping required failure handling with the behavior it protects. Each change needs one concrete intent and must be reviewable/verifiable after its dependencies. Split only for concrete delivery, risk or project boundaries; name shared contracts and order across repositories.
3. Resolve important uncertainty early, using a narrow real end-to-end path when useful. Defer supported variants only within agreed scope; do not defer required correctness or safety. Keep uncertain later changes provisional.
4. Map every acceptance criterion to responsible changes, expected result and sufficient proof. Reuse existing checks; state prerequisites and when to run them.
5. Check scope in both directions: cover all accepted behavior, remove hidden scope and merge unnecessary splits. One change or no new work is valid.

Sizing reference: [Writing Good Specs — Right-size the change](https://github.com/Fission-AI/OpenSpec/blob/main/docs/writing-specs.md#right-size-the-change).

## Return

- Overall outcome, non-goals and baseline for improvements.
- Proposed changes: title, repository/service, scope/behavior, dependencies and concrete reason for separation.
- Acceptance map: criterion → responsible changes → expected result → proof, prerequisites and timing.
- First step and unresolved decisions.
