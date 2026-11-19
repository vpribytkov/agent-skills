---
name: openspec-retrospective
description: "Use when explicitly asked for a delivery retrospective of a completed OpenSpec change, including time, rework, verification cost or review value. Read existing evidence without rerunning work."
---

# OpenSpec Retrospective

Analyze the requested completed or substantially completed change. Do not modify the repository or rerun builds, tests or runtime acceptance.

## Evidence

Read materially related implementation, child-review and repair sessions. Prefer primary session events, timestamps, commands/results, OpenSpec artifacts, Git history, source intent and PR/review records over agent summaries. Exclude unrelated work and stop when evidence supports the requested conclusions.
Distinguish facts, inference and hypotheses. Cite session/log identifiers, timestamps/events, commands or relevant diffs for material claims. Do not invent missing timestamps, sum overlapping work as elapsed time or treat measured and estimated durations alike.

## Analysis

- **Timeline:** distinguish implementation start, first working path, complete acceptance behavior, green required gates, apply completion, PR, review, repair and merge-ready state where evidence exists. Include actor, interval, activity and result; distinguish mostly-written code from working behavior.
- **Cost:** account for exploration, production/test implementation, check execution, runtime setup, diagnosis, code/fixture fixes, rework, review, user waiting, handoffs and context recovery. Show wall time separately from overlapping activity.
- **Verification:** give run/pass/fail counts, measured time and repeat reasons. Classify failures as production, fixture, environment, stale artifact, wrong invocation, expected intermediate failure or unknown. Identify repeated PASS runs with unchanged relevant inputs.
- **Rework and decomposition:** record trigger, replaced approach, repair, cause and avoidability. Relate task boundaries and discovered dependencies to actual change surfaces and invalidated code/evidence; recommend a different split only when this caused demonstrated waste.
- **Tools and context:** assess actual searches, reads, diffs, checks and compactions. Identify repeated discovery or expensive checks used as the inner loop; do not assume one tool is inherently better.
- **Review value:** distinguish material issues found before review from new independent findings, and explicit spec obligations from broader engineering findings. Include repair cost, repair regressions and review rounds where available.
- **Hypothesis/comparison:** test a supplied hypothesis as `CONFIRMED`, `PARTIALLY CONFIRMED` or `REJECTED`. Compare with an available relevant retrospective only when useful; explain limits on comparability and causal claims.

## Return

Start with at most seven summary bullets. Support them with the relevant timeline, quantitative breakdown, verification/rework evidence and review analysis; omit empty sections.
Return at most five root causes with evidence, mechanism, approximate cost and prevention point. Give at most three recommendations addressing demonstrated costs, each with expected benefit and confidence. Do not add mandatory skills, process layers or review rounds without evidence.
Save the detailed report outside the target repository. Return a concise summary and report path in chat.
