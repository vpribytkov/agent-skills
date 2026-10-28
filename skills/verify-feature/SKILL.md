---
name: verify-feature
description: Verify that implemented changes deliver an approved feature or milestone.
---

# Verify Feature

The user needs to check whether implemented changes deliver the intended feature or milestone.
Verify their combined result against approved requirements, not just individual PRs.

## Check
1. Read the request, approved scope and project rules. Derive acceptance criteria from requirements, not implementation; use the to-changes map if available.
2. Match each criterion to evidence. Check omissions and gaps between changes/services. Reuse results only while relevant inputs and assumptions remain valid.
3. Run only missing or invalidated authorized checks with existing tools. Choose the cheapest sufficient layer; require full E2E only where narrower checks are insufficient.
4. Probe the most plausible failure through its result and next system decision. Distinguish inspection, mocks and real execution.

## Return
- Evaluated feature/milestone, revisions and environment.
- Criterion → evidence (commands/results) → limitations.
- PASS: all required criteria proven; FAIL: observed violation; BLOCKED: missing required evidence/decision.
- Gaps and smallest next action.

Respect approved exclusions. No repairs, scope expansion or production changes without approval. PASS does not authorize deployment or replace owner approval.
