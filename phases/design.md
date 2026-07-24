# DESIGN

Design the smallest solution that satisfies the approved ANALYSIS artifact.
Do not modify production code.

## Work

- reconstruct the relevant current flow;
- propose the minimal solution;
- define boundaries, ownership, and contracts;
- describe applicable API, event, data, schema, and configuration changes;
- address compatibility, partial failure, concurrency, retries, duplication,
  slow dependencies, migration, rollout, and rollback;
- compare at least two viable approaches for each material choice, or explain
  why no second viable approach exists;
- justify added complexity against the simpler baseline and current scale;
- use diagrams only when they materially improve review.

Attack the provisional design before finalizing it. Revise or explicitly reject
each material finding.

For runtime behavior changes, determine how operators can observe activation,
attempts, successes, failures, skips, retries, and fallbacks. State why no
observability change is needed when existing signals are sufficient.

If ANALYSIS is incomplete or new product semantics are required, return
`BLOCKED` with `Next: BACK TO ANALYSIS`.

## Work-item graph

Create `WI-01...WI-N`. For each work item define:

- outcome;
- scope and non-scope;
- covered acceptance criteria;
- dependencies;
- affected components;
- expected write set;
- planned evidence and specific tests;
- done criteria;
- risks;
- whether it is parallelizable, with a reason.

Keep the graph acyclic. Put shared contracts, schemas, migrations, and generated
outputs behind explicit dependency boundaries. Parallelize only demonstrably
independent work.

Provide traceability:

| AC | Work item | Planned evidence | Type |
|---|---|---|---|

## Output artifact

Write the phase artifact to the exact output path supplied by the orchestrator.
Include:

- current flow and proposed solution;
- boundaries and contracts;
- alternatives and design-attack findings;
- compatibility, failure, migration, rollout, rollback, and observability;
- work-item graph;
- acceptance-criteria traceability;
- implementation and verification plan;
- unresolved decisions or accepted risks.

Return `SUCCESS` only when the design is grounded in the actual system, the
dependency graph is complete and acyclic, every acceptance criterion maps to
planned evidence, and the plan is executable.

Otherwise return `BLOCKED` with a concrete reason and next action.
