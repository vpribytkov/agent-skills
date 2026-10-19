---
name: create-pr
description: "Prepare local changes and create a pull request by checking scope and branch, committing narrowly, pushing, and opening a draft PR. Use when the user asks to create, open, publish, or prepare a PR from the current repository."
---

# Create PR

1. Read project instructions and any conditional Git or PR guidance. Project branch names, base branch, PR template, and acceptance rules override this skill.
2. Inspect `git status --short`, the full diff, untracked files, current branch, upstream, and remote default branch. Exclude unrelated user changes.
3. Never publish from the default branch. If the correct working branch is materially ambiguous, ask; otherwise create or switch to the branch required by the project.
4. Do not run verification solely to create a PR. Reuse existing results when available; otherwise report missing verification without triggering additional checks. Never claim an unverified result.
5. Stage only files in scope. Create a narrow commit with a clear imperative subject; do not rewrite suitable existing commits unless asked.
6. Push the current branch with upstream tracking. Never force-push without explicit approval.
7. Open a draft PR unless the user explicitly requests ready-for-review.
   Base the PR title on the associated task when one is established by the current context. Preserve its exact title and include its identifier, if available, without translating or rewriting it. Otherwise, use a concise descriptive title.
   Use the project template when required; otherwise write the description in Russian with these sections:
   - `## Что изменено` — briefly describe what was added, removed, fixed, or changed, focusing on observable behavior.
   - `## Зачем это нужно` — explain the problem being solved and why the change matters.
   - `## Как реализовано` — briefly explain non-obvious implementation decisions relevant to the reviewer.
   Include `## Связанные изменения` only when dependent PRs exist.
   Describe the actual change relative to existing behavior; do not present existing capabilities as newly added. Make the supported outcome and any material scope boundary clear without implying broader automation.
   Explain non-obvious implementation decisions through their reviewer-relevant purpose or consequence, rather than listing mechanisms. For complex behavioral changes, use a short concrete example when it clarifies the outcome; do not force examples into trivial PRs.
   Keep the description concise and reviewer-oriented. Omit redundant implementation details, generic filler, development history, test results, logs, commit hashes, and verification evidence.
   Mention risks, limitations, or intentional contract changes only when they materially affect the reviewer’s understanding.
8. Report the PR URL and any material blockers or remaining risks. Never merge or deploy without separate explicit approval.

For GitHub, prefer the available GitHub connector and use `gh` only when the connector cannot perform or inspect the required operation.
