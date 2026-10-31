---
name: coding-quality
description: >
  Apply when designing, writing, modifying, or reviewing repository code.
  Prefer the smallest complete change while keeping domain decisions,
  failure semantics, configuration, and verification explicit.
---

# Coding Quality

Solve the approved task with the smallest **necessary** change. Minimize unnecessary behavior, code, and dependencies, not characters at the expense of clarity or safety.

## Precedence

1. Explicit task, specification, and acceptance requirements.
2. Repository and project instructions.
3. Compatible existing local patterns.
4. This skill.

Do not change approved behavior, architecture, or scope merely to satisfy this skill.

## Choose and bound the change

- Before editing, identify the observable outcome and relevant callers, consumers, variants, contracts, tests, fixtures, and configuration. Inspect enough of the real path to know what must change.
- Prefer no new code when existing behavior already satisfies the task. Otherwise reuse repository code and patterns; then standard library or native platform features; then existing dependencies; only then implement a small local solution.
- Avoid speculative abstractions, wrappers, options, dependencies, configuration, compatibility paths, and recovery machinery. Add them only when a current requirement justifies their cost.
- Change every file required for correct behavior and verification, but nothing else. Preserve unrelated parsing, messages, interfaces, error handling, formatting, and supported behavior. No opportunistic rewrites or adjacent cleanup.
- If an unrelated defect deserves attention, report it separately. Small supporting changes are allowed when necessary for correctness, clarity, or safe verification; explain that dependency.
- Before handoff, compare the complete diff with the original request and approved requirements. Remove edits without a concrete necessity, even if they are harmless or pass tests.
- Do not optimize for raw line count: a shorter solution is better only when it remains equally understandable, correct, and safe.

## Make domain decisions clear

- Keep materially different domain outcomes distinguishable. Prefer top-down control flow and guard clauses when separate conditions lead to separate results; do not collapse causes and rediscover them later.
- Compound conditions are appropriate when their parts express one decision and separate causes do not matter. Do not split conditions mechanically.
- Keep related decisions and state transitions together. Extract lower-level mechanics only when they obscure the business flow; do not create helpers merely to shorten a function or hide syntax.
- Name variables and predicates by intent. Prefer local reasoning over clever expressions, hidden coupling, and unnecessary indirection.
- Keep abstraction levels coherent and reuse compatible repository conventions. Existing patterns are evidence, not proof of correctness.
- Preserve distinct success, unavailable, invalid, skipped, and failure states when the caller cares. Do not invent new result types or state models without a need.

## Configuration is data, not code

- Validate configuration schemas and semantic invariants, not the current committed values. Treat a value as fixed only when the specification explicitly requires it.
- Alternative valid configuration must work without implementation changes. Do not duplicate configurable policy in constants, branches, validators, defaults, or tests.
- Test parsing, invariants, and behavior with representative alternative configurations. Do not assert committed inventories or exact values unless they are a product contract.
- Check whether changing a valid configured value would force code or unrelated tests to change; if so, investigate hardcoding.

## Preserve failure behavior

- Follow established error-handling conventions and keep necessary validation at trust boundaries.
- Do not swallow meaningful failures, invent unrelated fallbacks, or discard useful causes when propagating errors.
- Preserve data-safety, security, and relevant accessibility behavior when simplifying or moving code. Do not redesign error handling without a task requirement.

## Testing and review

- Derive test expectations from requirements and behavior contracts, not implementation constants or committed configuration content.
- Make materially different behavior and outcomes visible in tests. Keep domain-relevant inputs and expected outcomes at the test case; use helpers for plumbing.
- Use the project's canonical verification and the cheapest checks that reliably prove the required behavior. Do not introduce test frameworks, redundant fixtures, or extra integration layers without need.
- In review, assess both correctness and necessity against the original task. A finding must identify a concrete behavior, risk, or avoidable maintenance cost and the smallest suitable correction.
- Do not demand stylistic rewrites or arbitrary limits on function size, parameters, nesting, or complexity. Fewer lines alone are not proof of better code.
