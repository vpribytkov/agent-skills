---
name: ensemble-code-review
description: Run three independent read-only review passes over the same frozen candidate: OpenSpec verification, full code review, and a minimally framed raw review. Aggregate validated material findings into one PASS/CHANGES result for Factory or direct use.
---

# Ensemble Code Review

Use this skill when a single review result should combine three independent perspectives over the same exact candidate.

## Contract

Input must identify the repository and the exact candidate boundary:

- repository path;
- exact base revision;
- exact head revision;
- PR link when one exists;
- associated accepted OpenSpec change when one exists.

Treat the candidate as frozen for the entire run. Do not modify source, tests, OpenSpec artifacts, PR metadata, comments, branches, or receipts while the three review passes are running.

The goal is maximum defect recall before repair, not agreement between reviewers.

## Required delegation

This skill is executed by a review executor that must have subagent delegation available.

Spawn all three child agents before waiting for any result so their work can proceed in parallel. Use fresh contexts with `fork_turns="none"`. Do not pass one child's findings to another.

If the host cannot create all three independent children with the required model/reasoning settings, report the limitation and do not silently degrade to fewer review passes.

### A. OpenSpec verification

Model: `gpt-6.1-sol`
Reasoning: `high`

Task:

- Resolve and use the installed `openspec-verify-change` skill.
- Verify the accepted OpenSpec change associated with this candidate.
- Use the same repository/base/head boundary as the other reviewers.
- Do not implement, repair, archive, sync, or mutate anything.
- Return verification issues and explicit limitations only.

This pass answers primarily: did the implementation completely and coherently realize the accepted change?

If the task legitimately has no associated OpenSpec change, return `NOT_APPLICABLE` with the reason. If the repository uses OpenSpec but the relevant change is ambiguous or unavailable, treat that as a review limitation/blocker rather than guessing.

### B. Full code review

Model: `gpt-6.1-sol`
Reasoning: `high`

Task:

- Resolve and use the installed `code-review-skill`.
- Review the whole candidate against the exact base/head, repository instructions, work item, accepted intent, and applicable verification evidence.
- Preserve the review skill's normal integration/system tracing behavior.
- Compare changed files and behavior to the original work item and approved intent. Flag concrete unnecessary rewrites or unrelated edits even when tests pass; do not use line counts or penalize necessary supporting changes.
- Do not mutate anything.
- Return material findings, verdict, and explicit unresolved limitations.

This is the primary system/code review pass.

### C. Raw review

Model: `gpt-6.1-sol`
Reasoning: `medium`

Do not load `code-review-skill`, `openspec-verify-change`, Factory review payload, findings from A/B, or accepted-change/verification prose unless the reviewer independently chooses to inspect repository-visible artifacts.

Give only:

- repository path;
- exact base;
- exact head;
- PR link if one exists.

Task text:

- when a PR link exists: `Review this PR.`
- otherwise: `Review this change.`

Do not add a checklist, minimum finding count, target failure categories, or instructions such as "find material issues".

This pass intentionally provides an independent, minimally framed search trajectory.

## Aggregate

Wait for all three children before taking any action.

The parent review executor owns aggregation:

1. Bind every result to the same base/head. Ignore findings derived from a different candidate.
2. Deduplicate by underlying failure path, not wording.
3. Validate proposed material findings against production code and task intent before returning them, especially findings from the raw reviewer.
4. Do not discard a finding merely because the other reviewers did not report it. Treat validated out-of-scope changes as material Factory findings, not optional style nits.
5. Distinguish:
   - confirmed material finding;
   - non-blocking spec/test-quality note;
   - unsupported/false-positive concern;
   - explicit verification limitation.
6. Apply the caller's configured priority/materiality threshold only after exploration and validation, not while deciding which child findings to inspect.

## Verdict

Return one ordinary review result to the caller.

- `CHANGES` when at least one confirmed finding meets the caller's blocking/materiality threshold.
- `PASS` only when no such finding remains and no unresolved limitation materially prevents that conclusion.
- An OpenSpec `NOT_APPLICABLE` result does not block PASS by itself when the task legitimately has no OpenSpec change.
- A failed/missing required child review is a limitation/blocker, not implicit PASS.

Keep the final output concise, but always include a source matrix after parent validation.

1. Verdict: PASS / CHANGES
2. Confirmed material findings, highest impact first
3. Reviewer coverage matrix
4. Reviewer summary
5. Relevant non-blocking notes only when useful
6. Verification limitations, if any
7. Which independent passes completed: OpenSpec / code-review / raw

### Reviewer coverage matrix

Build one row per normalized underlying failure path after deduplication and validation.
Do not create separate rows for wording variants of the same defect.

Use:

| Finding | OpenSpec verify | Code review | Raw | Status |
| --- | :---: | :---: | :---: | --- |
| <normalized failure path> | ✓ / — | ✓ / — | ✓ / — | confirmed / non-blocking / unsupported |

Rules:

- `✓` means that reviewer independently identified that failure path in its own result.
- `—` means it did not.
- `confirmed` means the parent validated the issue as real and material under the caller's threshold.
- `non-blocking` means real but below the blocking/materiality threshold.
- `unsupported` means the parent could not validate the concern or determined it was a false positive.
- Do not give a reviewer credit merely because it inspected the same file or adjacent code.
- Count uniqueness only after normalization and validation.

### Reviewer summary

Always add a compact per-reviewer summary using validated rows:

| Reviewer | Confirmed | Unique confirmed | Non-blocking | Unsupported |
| --- | ---: | ---: | ---: | ---: |
| OpenSpec verify | N | N | N | N |
| Code review | N | N | N | N |
| Raw | N | N | N | N |

A confirmed finding is unique when exactly one reviewer identified its normalized failure path.

This matrix is part of the normal review result so the caller can judge the marginal value of each independent pass across real PRs. Do not persist a separate historical ledger or cumulative telemetry unless explicitly requested.

Do not expose hidden chain-of-thought or create a separate review ledger.
