---
name: ensemble-code-review
description: "Use only when explicitly requested to combine three independent review perspectives over a frozen candidate. Optional deeper review, not the default code-review path."
---

# Ensemble Code Review

## Candidate and independence

- Resolve each repository's identity, checkout path, exact base and head, PR link if present, accepted intent/OpenSpec change or store, and dependency contract versions. Treat all participating heads as one frozen candidate set.
- Keep the run read-only: no source, tests, OpenSpec artifacts, branches, PR metadata/comments or receipts change during review.
- Run A, B and C for **every** repository as fresh native subagents with `fork_turns="none"`. Inherit the caller's actual selected runtime model and reasoning; do not pin or invent model versions.
- Respect concurrency limits; run passes sequentially when needed without dropping perspectives. If independent delegation or required access is unavailable, report a blocker.
- Reviewers read the target checkout's applicable project instructions and use explicit workdir paths. Do not share the parent conversation or other reviewers' findings, including findings from another repository.

## Three passes

### A. OpenSpec verification

Use the installed upstream `openspec-verify-change` skill against the exact candidate and dependencies. Check this repository's assigned obligations and its side of shared contracts; neighboring tasks supply context, not missing local implementation. Return issues and limitations without applying, repairing, syncing or archiving.
Return `NOT_APPLICABLE` only when the task legitimately has no OpenSpec change. An expected but missing or ambiguous change is a limitation/blocker.

### B. Full code review

Use the installed `code-review-skill` over the exact base/head, work item, accepted intent, dependencies and applicable verification evidence. Preserve its integration/system tracing.
Check each meaningful behavior change against an agreed obligation or a candidate-introduced regression it prevents. Respect exclusions; do not invent requirements to justify extra machinery.
Check the exact base before proposing a fix. Separate candidate defects from unrelated pre-existing problems and optional improvements. A pre-existing defect belongs in repair scope only when it demonstrably blocks an agreed obligation. Request removal of unnecessary candidate behavior instead of extending it further.
Return material findings, verdict, separate baseline/improvement observations and unresolved limitations.

### C. Raw review

Supply only repository identity/path, exact base/head and PR link if present. Task text is `Review this PR.` or `Review this change.`
Do not preload either A/B review skill, accepted-intent/verification prose, Factory payloads or findings. Do not seed checklists, finding quotas or target failure classes. The reviewer may independently inspect repository-visible artifacts.

## Validate and aggregate

Wait for all three results for every repository before aggregation or repair.
On a rerun, reuse a pass only while its exact local candidate, accepted obligations and dependent contracts remain unchanged; identify reused coverage. Joint evidence must match the current participating heads.

1. Bind every result to its repository and exact base/head; a different candidate is stale coverage.
2. Deduplicate underlying failure paths across repositories while preserving the originating repository/pass. Do not discard a finding because only one reviewer found it.
3. Validate findings against code, the exact base and accepted scope. Confirm both the failure and why its repair belongs in this change. Apply the caller's materiality threshold only after validation.
4. Separate confirmed candidate defects (including unnecessary changes), unrelated baseline/improvement observations, non-blocking spec/test notes, unsupported concerns and verification limitations. Unrelated observations do not become required repairs regardless of priority.
5. Check joint compatibility using actual producer/consumer evidence at the exact head tuple; separate local passes do not prove it. State what was traced or exercised and any gaps. Invalidate only affected passes and joint checks when a candidate or contract changes.

## Return

- One overall `CHANGES` when a confirmed candidate finding meets the blocking threshold; `PASS` only when none remains and required coverage is complete. If a required pass, repository part or joint check is missing, report the review as blocked without a PASS verdict. Legitimate OpenSpec `NOT_APPLICABLE` alone does not block PASS.
- Candidate revisions, confirmed findings in priority order with evidence and originating passes, completed/reused pass status per repository, joint compatibility evidence and material limitations.
- Include useful non-blocking observations separately. Keep reporting compact; add reviewer-value counts or a matrix only when requested, based on independently found, deduplicated and validated issues. Do not credit a child for a boundary finding discovered only during aggregation.
