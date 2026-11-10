---
name: ensemble-code-review
description: "Run three independent read-only review passes over the same frozen candidate: OpenSpec verification, full code review, and a minimally framed raw review. Aggregate validated material findings into one PASS/CHANGES result for Factory or direct use."
---

# Ensemble Code Review

Use this skill when a single review result should combine three independent perspectives over the same exact candidate.

## Contract

Input identifies one change's set of repository-scoped candidates (a single
repository remains valid). For each candidate provide:

- repository identity and checkout path;
- exact base revision;
- exact head revision;
- PR link when one exists;
- associated accepted OpenSpec change/store, shared by the set, when one exists;
- known inter-repository dependencies and contract versions.

Treat the entire candidate set as frozen for the run. Do not modify source, tests, OpenSpec artifacts, PR metadata, comments, branches, or receipts while the review passes are running.

The goal is maximum defect recall before repair, not agreement between reviewers.

## Required delegation

The review executor must be able to launch independent sessions in each target
checkout. Run A/B/C for every repository: two repositories require six passes.
Sequential execution is allowed and must respect the caller's concurrency limits;
never drop a perspective to fit those limits.

Each pass starts a fresh session with its repository checkout as working directory
from startup, loading that checkout's AGENTS.md, not another repository's rules or
conversation. For Codex, inspect installed `codex exec --help` and use
`codex exec --cd <checkout>` or a supported equivalent, preserving the model/reasoning
below and configured read-only permissions. A path in a `spawn_agent` prompt or a
later shell `cd` does not provide this guarantee. Do not pass findings between
independent reviewers, including reviewers of different repositories.

If the launcher cannot meet startup checkout, fresh context, model/reasoning or
permission requirements, report a blocker rather than simulate independent review.

### A. OpenSpec verification

Model: `gpt-6.1-sol`
Reasoning: `high`

Task:

- Resolve and use the installed `openspec-verify-change` skill.
- Verify this repository's assigned part of the shared accepted OpenSpec change/store;
  neighboring tasks provide contract context, not missing local implementation.
- Use the same repository/base/head boundary as its other reviewers and exact
  dependency versions supplied with the candidate set.
- Do not implement, repair, archive, sync, or mutate anything.
- Return verification issues and explicit limitations only.

This pass answers primarily: did this part completely and coherently realize its
accepted obligations, including its side of shared contracts?

If the task legitimately has no associated OpenSpec change, return `NOT_APPLICABLE` with the reason. If the repository uses OpenSpec but the relevant change is ambiguous or unavailable, treat that as a review limitation/blocker rather than guessing.

### B. Full code review

Model: `gpt-6.1-sol`
Reasoning: `high`

Task:

- Resolve and use the installed `code-review-skill`.
- Review the whole repository candidate against the exact base/head, its repository instructions, work item, shared accepted intent/change/store, known dependencies and applicable verification evidence.
- Preserve the review skill's normal integration/system tracing behavior.
- Do not mutate anything.
- Return material findings, verdict, and explicit unresolved limitations.

This is the primary system/code review pass.

### C. Raw review

Model: `gpt-6.1-sol`
Reasoning: `medium`

Do not load `code-review-skill`, `openspec-verify-change`, Factory review payload, findings from A/B, or accepted-change/verification prose unless the reviewer independently chooses to inspect repository-visible artifacts.

Give only:

- repository identity and checkout path;
- exact base;
- exact head;
- PR link if one exists.

Task text:

- when a PR link exists: `Review this PR.`
- otherwise: `Review this change.`

Do not add a checklist, minimum finding count, target failure categories, or instructions such as "find material issues".

This pass intentionally provides an independent, minimally framed search trajectory.

## Aggregate

Wait for current results from all three perspectives for every repository before
aggregation or repair. A completed pass may be reused only while its exact local
candidate, accepted obligations and dependent contract inputs remain unchanged;
identify reused coverage explicitly. Joint checks must match the current head tuple.

The parent review executor owns aggregation:

1. Bind every result to its repository and exact base/head. Results from a different
   candidate are stale, not completed coverage.
2. Deduplicate by underlying failure path within repositories and across their
   boundaries, not wording; preserve the originating repository/pass for each source.
3. Validate proposed material findings against production code and task intent before returning them, especially findings from the raw reviewer.
4. Do not discard a finding merely because the other reviewers did not report it.
5. Distinguish:
   - confirmed material finding;
   - non-blocking spec/test-quality note;
   - unsupported/false-positive concern;
   - explicit verification limitation.
6. Apply the caller's configured priority/materiality threshold only after exploration and validation, not while deciding which child findings to inspect.
7. Validate inter-repository compatibility against the exact participating heads
   (for example `head-backend` + `head-frontend`), using shared contracts and actual
   producer/consumer evidence. Record what was traced or exercised and any gaps;
   separate local PASS results do not prove joint compatibility. Do not credit a
   child for a boundary finding discovered only during aggregation. If a contract
   changes, invalidate affected dependent results and joint checks, not unrelated
   checks; revalidate the changed repository's candidate before a new verdict.

## Verdict

Return one overall PASS/CHANGES result for the whole candidate set to the caller.

- `CHANGES` when at least one confirmed finding meets the caller's blocking/materiality threshold.
- `PASS` only when no such finding remains and no unresolved limitation materially prevents that conclusion.
- An OpenSpec `NOT_APPLICABLE` result does not block PASS by itself when the task legitimately has no OpenSpec change.
- A failed/missing required repository part, child review or necessary joint
  compatibility check is a limitation/blocker, never implicit PASS.

Keep the final output concise, but always include a source matrix after parent validation.

1. Verdict: PASS / CHANGES
2. Confirmed material findings, highest impact first
3. Reviewer coverage matrix
4. Reviewer summary
5. Relevant non-blocking notes only when useful
6. Verification limitations, if any
7. Which independent passes completed per repository: OpenSpec / code-review / raw;
   exact heads and evidence for joint compatibility

### Reviewer coverage matrix

Build one row per normalized underlying failure path after deduplication and validation.
Do not create separate rows for wording variants of the same defect.

Use:

| Repository / boundary | Finding | OpenSpec verify | Code review | Raw | Status |
| --- | --- | :---: | :---: | :---: | --- |
| <repo or repo A → repo B> | <normalized failure path> | ✓ / — | ✓ / — | ✓ / — | confirmed / non-blocking / unsupported |

Rules:

- `✓` means that reviewer independently identified that failure path in its own result.
- `—` means it did not.
- For boundary findings, identify the originating repository session beside each
  `✓`; do not imply both repositories' reviewers found it.
- `confirmed` means the parent validated the issue as real and material under the caller's threshold.
- `non-blocking` means real but below the blocking/materiality threshold.
- `unsupported` means the parent could not validate the concern or determined it was a false positive.
- Do not give a reviewer credit merely because it inspected the same file or adjacent code.
- Count uniqueness only after normalization and validation.

### Reviewer summary

Always add a compact per-reviewer summary using validated rows:

| Repository | Reviewer | Confirmed | Unique confirmed | Non-blocking | Unsupported |
| --- | --- | ---: | ---: | ---: | ---: |
| <repo> | OpenSpec verify | N | N | N | N |
| <repo> | Code review | N | N | N | N |
| <repo> | Raw | N | N | N | N |

A confirmed finding is unique when exactly one repository/reviewer session
identified its normalized failure path across the whole candidate set.

This matrix is part of the normal review result so the caller can judge the marginal value of each independent pass across real PRs. Do not persist a separate historical ledger or cumulative telemetry unless explicitly requested.

Do not expose hidden chain-of-thought or create a separate review ledger.
