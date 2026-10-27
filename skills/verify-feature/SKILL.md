---
name: verify-feature
description: Verify an approved feature or milestone against its original outcome, reusing current evidence and checking material gaps.
---

# Verify Feature

Verify the requested outcome, not merely completion of its changes.
Use the to-changes acceptance map when available; it is not a prerequisite.

## Approach

1. Read the source request, explicit later scope approvals, linked changes
   and project verification rules. Derive expected outcomes from approved
   requirements and independent reference data, not from implementation alone.
   Surface material contradictions; do not silently weaken acceptance.

2. Identify the evaluated feature or milestone, repository revisions,
   configuration, artifacts and environment.
   Map every required criterion to evidence. Check omitted requirements
   and unproven assumptions between changes or services.
   Never present a partial milestone as acceptance of the whole feature.

3. Reuse evidence while its relevant inputs and assumptions remain valid.
   Trace the actual path to the observable result and next system decision.
   Distinguish source inspection, simulated inputs and real execution.
   Do not claim proof beyond the boundary actually exercised.

4. Execute only missing or invalidated authorized checks at the cheapest
   authoritative layer, using existing tools or focused disposable probes.
   Require full E2E only for a named property narrower evidence cannot prove.
   Check the most plausible remaining failure supported by the actual flow.
   Do not repeat PR review or complete suites merely because changes are combined.

5. Report missing tests/tooling and propose the smallest necessary addition.
   Do not silently repair code, rewrite tests/specs or expand acceptance.
   Keep checks within authorized environments; do not mutate production data
   or deployed systems without explicit approval.

## Output

- Verdict and exact evaluated scope:
  PASS — all required criteria have sufficient current evidence.
  FAIL — observed behavior violates a required criterion.
  BLOCKED — required evidence or an authoritative decision is unavailable.
- Criterion → actual evidence → result and limitations.
  Reference exact commands/results and relevant revisions where applicable.
- Material gaps, unverified boundaries and the smallest next action.

Approved exclusions are not blockers. Optional improvements are not requirements.
PASS does not authorize deployment or replace required owner approval.
