# Task planning

Use a plan when the user asks for one or when dependencies, decisions, or continuity
make it useful. Routine edits do not need a separate planning phase.

## One source of progress

- Reuse existing OpenSpec tasks, an issue checklist, or a task document. Do not create a parallel plan that repeats them.
- Keep the desired outcome, meaningful steps or dependencies, and how success will be checked. Add file paths when they clarify the work; do not maintain a file-by-file ledger.
- Track consequential decisions, blockers, completed milestones, and the next action. Update when these change, not after every tool call.
- Continue authorized work without waiting for plan approval unless the user requested a review gate or a material decision is unresolved.

## Continuity

For long work that may cross sessions, persist enough context to resume: current
state, key evidence, verification results, unresolved questions, and next action.
Keep this in the existing task record when possible.

If a separate local plan is useful and no destination is established, use
`<agent-root>/plans/<repo-name>/YYYYMMDD-<short-task-name>-progress.md`, where
`<agent-root>` is the active harness configuration directory. Keep its original
date when continuing the same task. Do not copy raw sensitive logs into the plan.

At completion, report the outcome, verification, and remaining material gaps.
A plan is a working aid, not an additional completion checklist.
