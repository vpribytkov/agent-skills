# OpenSpec conventions

## Change naming

For work associated with a Jira issue:

- Use change ID format `{jira-issue-lowercase}-{service-name}-{short-change-name}`.
- Derive `service-name` from the affected repository/service.
- Use lowercase kebab-case only.
- Create one OpenSpec change per affected service; do not combine services unless explicitly requested.
- If Jira issue or affected service is unknown, ask. Never invent either value.
- Jira-specific naming applies only to change IDs. Name durable capability specs by system behavior/business capability.

Example:

`AUTOV-19425` affecting `autodealer` and `bx-layout`:

- `autov-19425-autodealer-auth-bx-layout`
- `autov-19425-bx-layout-add-autodealer-source`

## Service mapping

When applying a change from a service repository:

- Select the change whose service segment matches the current repository.
- Do not modify another service unless explicitly requested.