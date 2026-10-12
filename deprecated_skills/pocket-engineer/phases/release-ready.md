# RELEASE_READY

Prepare the approved implementation for release without deploying it.

## Work

Prepare only what is applicable:

- deployment order;
- migrations, configuration, and feature flags;
- rollback procedure;
- metrics, logs, traces, and alerts;
- post-release smoke checks;
- material risks and cleanup.

For runtime behavior changes, verify that operators can determine activation,
volume, success, failure, and applicable skip, retry, and fallback behavior.
Return `BLOCKED` when existing or planned observability cannot provide that
evidence.

Create or update a branch, scoped commits, push, or pull request only when the
input capsule explicitly authorizes the action. Otherwise prepare the exact
draft or return `BLOCKED` with `Reason: USER_INPUT` and the smallest missing
authority.

Never merge or deploy to production.

If release preparation exposes an implementation, design, or product-contract
problem, return `BLOCKED` and recommend the earliest affected phase.

## Output artifact

Write the phase artifact to the exact output path supplied by the orchestrator.
Include:

- release and migration order;
- configuration and feature flags;
- rollback and post-release checks;
- observability and operational readiness;
- branch, commit, push, and pull-request details when applicable;
- remaining risks, accepted risks, and cleanup;
- the exact next authorized action.

Return `SUCCESS` only when every applicable release-readiness item is complete
or explicitly accepted as a risk.

Otherwise return `BLOCKED` with a concrete reason and next action.
