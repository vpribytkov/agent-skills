# DEVELOPMENT

Implement only the approved ANALYSIS and DESIGN artifacts and their work-item
graph.

## Work

- follow active global and project engineering rules;
- follow existing project patterns;
- keep every diff minimal and reviewable;
- implement only approved behavior, contracts, and architecture;
- add the planned tests and run relevant checks;
- record every deviation instead of changing scope silently.

Before writing or completing tests, enumerate the observable outcomes of the
changed behavior. Cover each outcome unless it is impossible by construction,
already covered at a higher level, or would only lock a private implementation
detail.

Treat existing tests as behavioral contracts. Change an expectation only when
an approved acceptance criterion intentionally changes behavior. Prefer public
or package-level entry points and add a regression test for a bug when feasible.

If implementation requires new product behavior, return `BLOCKED` with
`Next: BACK TO ANALYSIS`.

If implementation requires a material design, contract, dependency, work-item,
or write-set change, return `BLOCKED` with `Next: BACK TO DESIGN`.

## Delegation

The phase worker owns integration and may delegate independent ready work items
when supported.

For every delegated work item provide exact scope, non-scope, dependencies,
allowed write set, expected evidence, and required checks. Use separate
branches or worktrees when available. Do not let delegated workers change the
approved design, canonical state, other work items, or perform merge, push, or
deployment.

Integrate results one at a time in dependency order. Inspect each diff, reject
out-of-scope changes, run targeted checks after integration, and run combined
checks after every parallel wave. Execute sequentially when independence or
isolation is uncertain.

## Final self-review

Before returning:

- review the integrated diff as a teammate's pull request;
- map every changed line and file to an approved work item;
- remove unrelated refactoring, formatting, and cleanup;
- verify that approved behavior and design were preserved;
- verify tests cover behavior rather than implementation details;
- record deviations and discovered defects;
- fix in-scope defects and rerun affected checks.

## Output artifact

Write the phase artifact to the exact output path supplied by the orchestrator.
Include:

- work-item statuses and execution waves;
- implemented changes and deviations;
- targeted and combined verification results;
- changed files and diff statistics;
- branch, commit, and pull-request details when available;
- self-review findings and fixes;
- local verification commands;
- remaining risks and review focus.

Return `SUCCESS` only when every required work item is complete, combined checks
pass, self-review is complete, and the implementation is ready for human review.

Otherwise return `BLOCKED` with a concrete reason and next action.
