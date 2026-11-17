---
name: to-changes
description: Select and justify code-grounded OpenSpec change boundaries for a feature, issue or TDR; defer implementation design to factory.
---

# To Changes

The user has a feature description, issue or technical design and needs a decomposition into OpenSpec changes.
Determine what to implement, in which increments and in what order. Select and justify change boundaries, not the design or implementation of those changes.

## Plan

1. Read the source request, approved decisions, project rules and enough relevant code/tests to establish the baseline. Identify the complete desired behavior, acceptance criteria, constraints, failure handling, what already works and what remains. Flag unresolved product decisions instead of inventing them.
2. Consider materially different decomposition strategies where applicable: sequential functional or processing stages, independently deliverable capabilities, and narrow end-to-end increments followed by extensions. Compare different assignments of shared contracts, state and integration work, as well as different completion orders; do not merely split or merge one initial grouping. Do not invent alternatives that violate real dependencies.
3. Select cohesive, reviewable and verifiable increments by delivered behavior, not technical layers or code size alone. Each change needs one intent, scope, observable outcome after dependencies and concise acceptance criteria. An intermediate technical capability is valid; it need not deliver a complete user-facing feature or be independently enabled in production. Keep failure handling and the integration necessary for an increment to work in its scope. Do not invent temporary functionality to make an increment independently valuable.
4. Choose boundaries by comparing total implementation and verification complexity, not simply number or size of changes. Consider rework, extra integration/regression testing, coordination, complexity, and the benefits of isolating substantial uncertainty or independently deferring/delivering work. Repeatedly touching a component is not automatically rework: name the concrete added cost. Do not split by repository, service, UI/API, implementation layer or supported variants merely because they can be separated. Split only when the concrete benefit outweighs the additional cost; avoid combining work into an unreasonably large or risky change. Use qualitative evidence from the TDR and code; do not invent numerical estimates.
5. Order the changes to manage real dependencies and minimize total complexity. A narrow end-to-end path is an option when it reduces integration risk, not the default. Distinguish **when to investigate** a technical uncertainty from **when to implement** the associated capability: an early investigation does not itself justify a separate or first implementation change. Identify the evidence needed and when to obtain it; recognize genuine implementation dependencies when investigation alone is insufficient.
6. Map every source requirement and acceptance criterion to responsible changes and concise observable completion criteria. Account for safe intermediate states, integration ownership and cross-repository dependencies. Check coverage in both directions: split oversized changes and merge unnecessary splits. One change or no new work is valid; keep uncertain later changes provisional.

## Scope boundary

Leave detailed API and data schemas, algorithms and SQL implementation, transaction/concurrency mechanisms, class/module structure, technical design alternatives and detailed implementation tasks to `factory` (`grill-with-docs`, `openspec-explore`, `openspec-propose`).

Preserve explicit TDR constraints and decisions without expanding them into implementation plans. Read code only as far as necessary to understand the baseline, feasibility of boundaries and dependencies. Do not create OpenSpec artifacts during decomposition.

## Self-review → Revise

Before presenting the result, reread the source and challenge the proposed decomposition:

- Does every change have one clear intent, an observable outcome and verifiable completion criteria?
- Are there oversized changes or artificial splits by layers, services or variants? Would merging lower total cost without creating undue risk?
- Could a different assignment of shared work or different completion order simplify delivery? Am I mistaking early risk investigation for an implementation dependency?
- Are requirements, failure behavior, intermediate safety, dependencies and integration responsibilities fully covered?
- Have I invented behavior or implementation decisions, or drifted into design instead of selecting boundaries?

Revise any defects and repeat the review after material changes. Present only the revised result, not the internal checklist.

## Output

Start with a concise change map:

| Change | Intent | Observable outcome | Dependencies |
|---|---|---|---|

Then briefly provide:

- Scope boundaries and the concrete reasons for splitting.
- Source requirements mapped to changes, with concise observable acceptance.
- Important integration responsibilities and cross-change dependencies, without implementation design.
- Unresolved decisions that materially affect boundaries.
- Recommended implementation order, the strongest plausible alternative and its decisive trade-off; distinguish early uncertainty checks from implementation order.

Keep the result short enough to review in a few minutes. Do not produce detailed technical specs or Jira-ready implementation documents.

Decomposition only. Do not edit files or create issues, changes or PRs unless explicitly requested; that authorization does not expand this skill into implementation design.
