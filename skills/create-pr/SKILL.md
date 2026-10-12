---
name: create-pr
description: "Prepare local changes and create a pull request by checking scope and branch, running relevant verification, committing narrowly, pushing, and opening a draft PR. Use when the user asks to create, open, publish, or prepare a PR from the current repository."
---

# Create PR

1. Read project instructions and any conditional Git or PR guidance. Project branch names, base branch, PR template, and acceptance rules override this skill.
2. Inspect `git status --short`, the full diff, untracked files, current branch, upstream, and remote default branch. Exclude unrelated user changes.
3. Never publish from the default branch. If the correct working branch is materially ambiguous, ask; otherwise create or switch to the branch required by the project.
4. Run relevant verification and record the exact commands and results. Never claim a check that did not complete successfully.
5. Stage only files in scope. Create a narrow commit with a clear imperative subject; do not rewrite suitable existing commits unless asked.
6. Push the current branch with upstream tracking. Never force-push without explicit approval.
7. Open a draft PR unless the user explicitly requests ready-for-review. Use the project template when one exists; otherwise use exactly these sections in this order:
   - `## Что изменено` — concise player-visible, runtime, configuration, and operational changes.
   - `## Зачем это нужно` — product context, player problem, and qualitative outcome.
   - `## Как это сделано` — implementation approach, authority boundaries, fallbacks, and verification.
   Put any required risks, follow-ups, or intentional contract changes inside the relevant section; do not add extra sections unless project instructions or the user require them.
8. Report the PR URL, source/base branches, created commit, actual verification, and remaining risks. Never merge or deploy without separate explicit approval.

For GitHub, prefer the available GitHub connector and use `gh` only when the connector cannot perform or inspect the required operation.
