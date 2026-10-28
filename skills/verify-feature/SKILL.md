---
name: verify-feature
description: Verify a feature or milestone against approved acceptance criteria across its changes.
---

# Verify Feature

Read approved requirements and scope decisions, linked changes and project checks.
Use the to-changes acceptance map when available; derive expectations from requirements, not the implementation under test.

## Check
- Map every criterion to evidence; look for omitted requirements and gaps between changes/services.
- Reuse proof while relevant inputs and assumptions remain valid. Run only missing or invalidated authorized checks using existing tools.
- Use the cheapest authoritative layer. Require full E2E only for a property narrower checks cannot prove.
- Probe the most plausible remaining failure through its outcome and next decision. Distinguish source inspection, mocks and real execution; do not overstate proof.
- Respect approved exclusions. Report missing tooling; do not repair code, tests or specs, expand acceptance or mutate production without explicit approval.

## Return
- Scope, revisions/environment and verdict: PASS (all required criteria proven), FAIL (observed violation), or BLOCKED (missing evidence/decision).
- Criterion → commands/results or other evidence → limitations.
- Material gaps and smallest next action.

A partial milestone is not the whole feature. PASS does not authorize deployment or replace owner approval.
