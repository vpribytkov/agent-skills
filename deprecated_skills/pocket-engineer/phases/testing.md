# TESTING

Independently verify the final integrated implementation against the approved
acceptance criteria. Do not modify the approved implementation.

## Work

- reconstruct acceptance from approved artifacts rather than DEVELOPMENT
  reasoning;
- verify the integrated repository state, not isolated worker branches;
- prefer fresh executable evidence over code inspection;
- minimize manual testing;
- record prerequisites, steps, expected results, and affected AC IDs for every
  manual check.

Use these acceptance-criterion statuses:

- `PASS` — verified behavior satisfies the criterion;
- `FAIL` — verified behavior violates the criterion;
- `BLOCKED` — the criterion cannot currently be verified;
- `ACCEPTED RISK` — the user explicitly accepted the specific unresolved risk.

Treat `automated`, `manual`, and `inspection` as evidence types, not statuses.
A manual check counts as `PASS` only after it has been executed successfully.

For each acceptance criterion report:

| AC | Evidence | Evidence type | Status | Notes |
|---|---|---|---|---|

When verification exposes an implementation defect, return `BLOCKED` with
`Next: BACK TO DEVELOPMENT`.

When it exposes a design or contract defect, return `BLOCKED` with
`Next: BACK TO DESIGN`.

When it exposes missing or incorrect product semantics, return `BLOCKED` with
`Next: BACK TO ANALYSIS`.

## Output artifact

Write the phase artifact to the exact output path supplied by the orchestrator.
Include:

- the acceptance-criterion evidence table;
- totals by status and evidence type;
- executed manual checks;
- gaps, risks, and unavailable evidence;
- exact verification commands and evidence references;
- the final integrated repository state.

Return `SUCCESS` only when every acceptance criterion is `PASS` or
`ACCEPTED RISK`, and every accepted risk is already recorded in canonical
state.

Otherwise return `BLOCKED` with a concrete reason and next action.
