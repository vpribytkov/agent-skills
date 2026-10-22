# Go integration test workflow

Use this workflow for Go integration tests, DB-backed tests, repository integration tests, and service tests that verify database behavior.

Integration tests should make the input → behavior → observable DB result clear.

## Test shape

Prefer table-driven integration tests.

For a method or behavior, use one test function with multiple cases instead of separate test functions per scenario.

Prefer:

```go
func TestService_ProcessVinItemUpdateIntegration(t *testing.T) {
    cases := []struct {
        name    string
        prepare func(ctx context.Context, t *testing.T, deps testDeps) input
        input   input
        want    expectedResult
        wantErr require.ErrorAssertionFunc
    }{
        ...
    }

    for _, tc := range cases {
        t.Run(tc.name, func(t *testing.T) {
            ...
        })
    }
}
```

Avoid creating separate top-level test functions for each case when they test the same method or integration behavior.

Avoid:

```go
TestService_ProcessVinItemUpdateIntegration_savesPersonalData
TestService_ProcessVinItemUpdateIntegration_skipsEmptyOldVIN
TestService_ProcessVinItemUpdateIntegration_rollsBackPersonalDataOnStaleEvent
```

Prefer:

```go
TestService_ProcessVinItemUpdateIntegration
```

with named table cases:

```go
"saves personal data"
"skips empty old VIN"
"rolls back personal data on stale event"
```

## Scenario readability

Each table case should make the scenario clear:

* what data exists before the action;
* what input is passed to the method;
* what observable DB result is expected;
* what error or no-error behavior is expected.

Keep domain-relevant input and expected values visible in the test body.

Use `prepare`, `assert`, or fixture helpers only to hide boring plumbing, not the core scenario.

Do not hide the expected business result inside broad helper functions.

## Database assertions

Integration tests should verify observable behavior through the database or public repository/service behavior.

When the purpose is DB behavior, prefer checking the result with a direct `SELECT` or existing repository read that clearly reflects the persisted state.

Do not assert private implementation details.

Do not test private helpers directly.

## Fixtures and cleanup

Make fixture ownership explicit.

Separate:

* persistent fixture data that needs cleanup;
* action data created by the method under test;
* external boundary expectations;
* rollback-only setup.

Register cleanup close to the data it owns, or return a fixture object that owns cleanup.

Avoid mixing persistent fixture setup and action-specific setup into one unclear setup block.

## Mocks in integration tests

Avoid mocks in integration tests by default.

Use real DB/repository behavior for the integration boundary being tested.

Mocks are allowed only for dependencies outside the integration concern, such as:

* external services;
* message publishers;
* clients unrelated to the DB behavior under test;
* expensive or unavailable infrastructure;
* nondeterministic boundaries such as time, network, or async side effects.

Before adding a mock:

1. Search for an existing mock or fake used by nearby tests.
2. Prefer reusing existing generated mocks.
3. If a new mock is required, generate it using the project's standard tooling.
4. Do not hand-write bespoke mocks unless nearby project tests already use that pattern or generation is unavailable.

For this codebase, prefer existing mock generation workflows such as:

```bash
avito codegen
```

or:

```bash
make mockery
```

Use the command that matches the existing project pattern.

If unsure which generator is standard, inspect nearby mocks, Makefile targets, codegen config, or project instructions before creating a mock.

## Existing pattern first

Before writing or changing an integration test, inspect nearby integration tests for:

* test function naming;
* table-driven case structure;
* fixture setup;
* cleanup pattern;
* DB assertion style;
* mock usage;
* generated mock location;
* integration build tags or command style.

Follow the closest existing pattern unless it is clearly incompatible with the task.

## Verification

Run the narrowest reliable integration test command first.

Prefer targeted commands such as:

```bash
go test -tags=integration ./internal/integration_tests -run TestService_ProcessVinItemUpdateIntegration
```

Then broaden only when needed.

If mock generation changed files, run the relevant generator and include generated files only when they are required.

Before finishing, verify:

* the integration test is table-driven when it covers multiple scenarios for the same method;
* expected values are visible at the test case level;
* mocks are avoided unless justified;
* any new mock follows existing generated mock patterns;
* cleanup ownership is clear;
* focused integration tests pass or skipped verification is explained.

## Coverage level

Use the narrowest integration level that covers the actual risk.

Storage/repository integration is enough for isolated SQL, mapping, constraint, or persisted-field behavior.

Service-level integration is expected when risk involves service orchestration, transaction boundaries, repo-manager wiring, rollback, old/new decisions, skipped/no-op/status-only behavior, or duplicate side-effect prevention.

Unit tests + storage integration do not replace service-level integration unless there is concrete evidence that the service layer adds no relevant orchestration/transaction/wiring/rollback risk.

If that evidence is missing, absent service-level integration is a readiness gap, not polish.