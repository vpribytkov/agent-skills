---
name: openspec-retrospective
description: Forensic retrospective for a completed OpenSpec change. Reconstruct timeline, time allocation, rework, verification cost, decomposition quality, and review value from primary logs. Do not modify code.
---

# OpenSpec Retrospective

Analyze a completed or substantially completed OpenSpec change after implementation.

This is a retrospective / delivery RCA, not code review and not implementation.

## Sources

Prefer, in order:

1. Codex session JSONL logs for implementation/review/repair.
2. OpenSpec proposal/specs/design/tasks.
3. Git diff/history.
4. Issue / source intent.
5. PR and review comments.
6. Agent telemetry or summaries only as secondary evidence.

Prefer primary events, timestamps, commands, outputs, diffs, and repository state over agent self-reports.

Do not rerun builds, tests, or runtime acceptance.
Do not modify the repository.

Find all materially related sessions, including child/subagent sessions when present, and exclude unrelated work.

## Analysis

### 1. Timeline

Reconstruct the delivery timeline and distinguish:

- implementation start;
- production code mostly written;
- first working happy path;
- all acceptance behavior first working;
- all required gates green;
- apply completion;
- PR creation;
- independent review;
- repair;
- merge-ready state.

For each phase report start, end, wall-clock, actor/session, material activity, and result.

Do not invent missing timestamps.

### 2. Time allocation

Measure or estimate time spent on:

- codebase exploration;
- production implementation;
- test implementation;
- test/build execution;
- runtime setup and acceptance;
- diagnosis;
- production fixes;
- test/fixture fixes;
- rework;
- review and repair;
- user waiting;
- orchestration/handoffs;
- context compaction/recovery.

Do not double-count overlapping intervals.

Clearly mark measured values vs inference.

### 3. Verification ledger

Build:

| category | runs | pass | fail | measured time | repeat reasons |

Classify failures as:
- production defect;
- test/fixture defect;
- environment/setup failure;
- stale artifact;
- wrong invocation;
- expected intermediate failure;
- unknown.

Identify repeated PASS runs where relevant inputs did not change.

### 4. Rework register

List meaningful rework:

`timestamp | area | trigger | first implementation | repair | root cause | avoidable?`

Include reopened tasks, wrong diagnosis, reverted/replaced solutions, review-driven fixes, and test-driven rework.

### 5. Task decomposition

For each top-level OpenSpec task block, compare:

- intended scope;
- actual systems/files touched;
- dependencies known before apply;
- dependencies discovered during apply;
- implementation/test/rework cycles;
- whether later work invalidated earlier code or evidence;
- whether the block ended in a stable state.

Assess whether decomposition matched the actual atomic change surface.

Only recommend different decomposition when there is concrete evidence that the current split caused rework or invalidated evidence.

### 6. Context and tooling

Analyze actual use of:
- structural/codegraph tools;
- text search;
- broad/repeated reads;
- diffs;
- focused tests;
- full gates;
- compactions.

Do not assume one tool is always better.

Identify late dependency discovery, repeated context loading, expensive checks used as inner development loops, and whether compaction was natural or caused by incremental rediscovery.

### 7. Review value

If independent review occurred, report:

- material issues found before review;
- material issues first found by reviewer;
- findings already explicit in OpenSpec;
- findings requiring broader engineering reasoning;
- repair time;
- regressions introduced by repair;
- review rounds to merge-ready.

Assess review value relative to its cost.

### 8. User hypothesis

If the user provides a hypothesis, test it explicitly and return:

- CONFIRMED
- PARTIALLY CONFIRMED
- REJECTED

with evidence.

Do not invent a hypothesis when none is supplied.

### 9. Comparison

If a comparable previous retrospective exists, compare:

- apply wall-clock;
- time to first working vertical slice;
- verification share;
- failed runs;
- compactions;
- review findings;
- repair time;
- user intervention;
- handoff overhead.

State when tasks are not comparable enough for causal conclusions.

### 10. Root causes

Return at most 5 root causes, highest impact first.

For each:
- evidence;
- mechanism;
- category;
- approximate cost;
- prevention point.

### 11. Recommendations

Return at most 3 recommendations.

Each must:
- address a demonstrated repeated cost;
- avoid adding process layers without evidence;
- state expected benefit;
- state confidence.

Do not propose new mandatory skills or review rounds merely because they are conceivable.

## Output

Start with:

### Executive Summary
Maximum 7 bullets.

Then:

1. Timeline
2. Quantitative breakdown
3. Verification ledger
4. Rework register
5. Task decomposition
6. Context/tool analysis
7. Review value
8. Hypothesis result
9. Root causes
10. Recommendations

Use labels:

- **FACT**
- **INFERENCE**
- **HYPOTHESIS**
- **RECOMMENDATION**

For strong claims include primary evidence:
- session/log identifier;
- timestamp;
- event/line when available;
- command/test;
- relevant file/diff.

Save the full report outside the repository.
Return only a concise summary plus report path in chat.