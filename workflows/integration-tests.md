# Go integration tests

Use for Go tests that cross a database, repository, or service boundary. Follow
nearby tests and the repository's existing commands, fixtures, and build tags.

## Cover the actual boundary

- Use storage/repository integration for isolated SQL, mapping, constraints, or persisted fields.
- Exercise the service path when the risk involves orchestration, transaction boundaries, repository-manager wiring, rollback, old/new decisions, no-op behavior, or duplicate side effects. Unit and storage checks do not prove those service behaviors.
- Derive expected outcomes from the behavior contract. Make initial data, action, expected persisted state, and error/no-error result visible in the scenario.
- Prefer named table cases for related scenarios when they remain readable; follow the closest suitable local structure.
- Assert observable state with a direct `SELECT` or existing repository read. Do not use private implementation details or diagnostic messages as proof of persistence or rollback.

## Reuse fixtures and infrastructure

- Use the real DB/repository for the boundary under test. Reuse existing setup and cleanup; keep ownership of persistent fixtures and action-created data clear.
- Keep domain inputs and expected results in the test body. Let helpers hide setup plumbing, not the business outcome.
- Mock only dependencies outside the integration concern, such as an external service, publisher, or nondeterministic boundary.
- Reuse nearby generated mocks or fakes. If a new mock is needed, inspect generated files, build targets, and generation configuration for the project's standard generator; use bespoke mocks only where local practice or unavailable generation warrants them.

## Run and inspect

Use the repository's narrowest reliable command. For repositories using the
`integration` build tag, a typical targeted command is:

```bash
go test -tags=integration ./path/to/package -run '^TestService_ProcessIntegration$' -count=1 -v
```

Check that the intended tests actually ran with the required infrastructure.
A successful exit with no matching tests or skipped DB setup is not a pass.
Run the relevant generator if mock definitions changed and include required generated
files. Broaden verification only for an affected boundary or a repository requirement.
Report the command, actual result, and any infrastructure or coverage gap.
