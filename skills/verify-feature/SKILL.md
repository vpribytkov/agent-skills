---
name: verify-feature
description: "Use when explicitly asked to verify an implemented feature or milestone against approved acceptance, especially across multiple changes. Not an automatic gate for each code change."
---

# Verify Feature

Verify the combined implemented result against approved requirements. Respect exclusions; do not repair, expand scope or change production without authorization. PASS does not authorize deployment or replace owner approval.

## Check

1. Read the request, approved scope and project rules. Derive acceptance from requirements, not implementation; reuse a `to-changes` map if available. Resolve discoverable context first, then ask only for consequential missing decisions and pause dependent checks.
2. Inspect current code/tests, relevant archived OpenSpec changes and recorded results. Match criteria to evidence and inspect gaps between changes/services. Completed tasks and historical PASS labels are not proof. Reuse results only while relevant revisions, inputs and assumptions remain valid.
3. Before execution, present criterion/source → expected result → reusable evidence or planned check. Wait for approval only when the user requested it.
4. Run only missing or invalidated authorized checks with existing tools at the cheapest sufficient layer. Use real runtime/service proof where those semantics determine the outcome; use full end-to-end checks only when narrower evidence is insufficient.
5. Probe the most plausible failure through its actual result and next system decision. Distinguish inspection, mocks and real execution; do not report skipped, failed or unknown checks as passed.

## Return

- Feature/milestone, evaluated revisions and environment.
- Updated acceptance map with actual evidence, commands/results, criterion status and limitations; identify reused evidence and its scope.
- `PASS`: all required criteria proven. `FAIL`: an observed requirement violation. `BLOCKED`: required evidence or a decision is missing.
- Remaining gaps and the smallest next action.
