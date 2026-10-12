# ANALYSIS

Establish the task contract from the real project before proposing a solution.
Do not modify production code.

## Work

Before requesting user input:

- read the task and every linked source;
- inspect the relevant project goals, roadmap, architecture, ADRs, prior task
  artifacts, and established constraints;
- inspect the current implementation, entry points, call and data flows, tests,
  analogues, contracts, documentation, configuration, and relevant git history;
- distinguish authoritative current decisions from stale or superseded material;
- separate discoverable facts from decisions that genuinely require the user.

Review only context relevant to the task. Do not inventory the entire repository
or pull downstream goals into scope.

When a material decision cannot be inferred, return `BLOCKED` with:

- `Reason: USER_INPUT`;
- what is already known;
- why the answer cannot be inferred;
- viable options and their consequences;
- a recommendation;
- the exact question to ask.

## Bugs and anomalies

For a bug, regression, incident, or anomaly:

- record observed and expected behavior;
- identify the divergence point in the code path or system boundary;
- maintain hypotheses with supporting and counter-evidence;
- discard disproven hypotheses;
- establish the root cause before proposing a fix, or record the strongest
  evidence-backed hypothesis and the missing evidence;
- prefer a reproducible check or regression test that fails before the fix;
- choose the smallest solution that addresses the cause rather than the symptom.

If observability fails, retry once when the failure appears transient, then use
another available evidence path. Return `BLOCKED` only after safe
uncertainty-reducing work is exhausted.

## Acceptance criteria

Assign stable IDs: `AC-01`, `AC-02`, and so on.

Make every criterion observable, testable, or explicitly manual. Do not invent
specificity or hide unresolved assumptions inside acceptance criteria.

## Output artifact

Write the phase artifact to the exact output path supplied by the orchestrator.
Include:

- goal;
- relevant project context and constraints;
- current behavior → desired behavior;
- scope and non-goals;
- numbered acceptance criteria;
- material assumptions and what breaks if each is false;
- open decisions;
- unavailable context;
- evidence and unresolved uncertainty.

Return `SUCCESS` only when current behavior, relevant architecture, prior
decisions, and project state are established, and every material gap is resolved
or explicitly recorded.

Otherwise return `BLOCKED` with a concrete reason and next action.
