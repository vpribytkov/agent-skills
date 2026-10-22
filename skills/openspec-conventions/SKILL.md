---
name: openspec-conventions
description: "Apply installed OpenSpec command usage, Jira-linked change naming, and service mapping alongside the relevant OpenSpec workflow."
---

# OpenSpec conventions

These conventions supplement the selected OpenSpec workflow; they do not replace propose/apply/review skills. Repository instructions take precedence. Do not impose Jira naming on tasks that are not associated with Jira.

## Installed command

Use the existing installation. On Windows, use the known per-user npm shim (or an explicitly configured machine-local path):

```powershell
& "$env:APPDATA\npm\openspec.cmd" <arguments>
```

Do not probe PATH, use `npx`, or reinstall it on Windows. On Windows, run the installed command with `sandbox_permissions="require_escalated"`. On other systems, use the existing configured OpenSpec command. If unavailable, report the tool/access gap instead of guessing an installation path.

Supported forms from the existing workflow:

- `status --change '<change>' --json`
- `instructions apply --change '<change>' --json`
- `validate '<change>' --type change --strict`

Do not use `validate --change`.

## Change naming

For work associated with a Jira issue:

- Use change ID format `{jira-issue-lowercase}-{service-name}-{short-change-name}`.
- Derive `service-name` from the affected repository/service.
- Use lowercase kebab-case only.
- Create one OpenSpec change per affected service; do not combine services unless explicitly requested.
- If Jira issue or affected service is unknown, ask. Never invent either value.
- Jira-specific naming applies only to change IDs. Name durable capability specs by system behavior/business capability.

Example:

`TASK-123` affecting `service-a` and `service-b`:

- `task-123-service-a-auth-service-b`
- `task-123-service-b-add-service-a-source`

## Service mapping

When applying a change from a service repository:

- Select the change whose service segment matches the current repository.
- Do not modify another service unless explicitly requested.
