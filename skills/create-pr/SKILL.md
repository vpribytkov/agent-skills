---
name: create-pr
description: "Use when asked to create or update a PR, or write its title and description. Prepare the current changes and publish a draft only when publication is requested."
---

# Create PR

Writing a title or description alone does not authorize commits, pushes or PR changes.
Follow project instructions, branch/base rules and required PR templates.

## Prepare and publish

1. Inspect status, staged and unstaged task diffs, untracked files, current branch/upstream and remote default/base branch. Preserve unrelated user changes; stage only the requested scope.
2. Never publish from the default branch. Choose the working branch/base from project rules and context, creating or switching to the task branch when needed. Ask only if material ambiguity remains; do not switch across unresolved user changes.
3. Do not run tests, builds or runtime checks solely to create a PR. Reuse existing verification results with their actual scope and report missing evidence honestly.
4. When publication is authorized, create a narrow commit if needed and push the current branch with upstream tracking. Preserve suitable existing commits; never force-push without explicit approval.
5. Open a draft unless the user requests ready-for-review. For an existing PR, update the requested fields without changing its readiness implicitly.

## Title and body

Use the associated task's exact title and identifier when established; do not translate or rewrite it. Otherwise use a concise descriptive title.
Unless a required project template says otherwise, write the body in Russian:

- `## Что изменено` — observable changes relative to the previous behavior.
- `## Зачем это нужно` — the problem and how this change achieves the requested outcome. For a fix, explain the cause; label an unconfirmed cause as a hypothesis.
- `## Как реализовано` — non-obvious decisions and their reviewer-relevant purpose or consequence.
- `## Связанные изменения` — only when dependent PRs exist.

Keep the body concise. Include material scope limits, risks or changed contracts; omit routine implementation detail, development history, logs, hashes and test evidence. A short example is useful only when it clarifies a complex behavior change.
When publishing, put available verification evidence in a separate PR comment with commands/results and material gaps. Do not place it in the body or rerun checks to fill the comment.

For GitHub, prefer the GitHub connector; use `gh` when it cannot perform the required operation. Return the PR URL and material blockers or remaining risks. Never merge or deploy as part of this skill.
