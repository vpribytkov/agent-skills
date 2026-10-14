---
name: openspec-summarize-change
description: Summarize a specification or OpenSpec change in up to 5 short technical statements, preserving mechanisms that materially increase implementation scope.
---

Read the supplied specification and its available proposal, design, requirements, and tasks. Describe the requested change, not its completion status.

Return up to five concise technical bullets in the user's language.
Use fewer when sufficient. Treat 40–60 words as a preference, not a cap: material interfaces, state-lifecycle decisions and behavior restrictions must remain visible. Each bullet describes one coherent change.

- Name the component and concrete change in behavior, API, or responsibility.
- Treat Core and Java as separate services and assign every bullet an explicit owner prefix: `[CORE]`, `[JAVA]`, or `[CROSS-SERVICE]`.
- Keep one service owner per bullet. Do not combine Core and Java implementation changes in one bullet merely because they implement the same feature.
- Use `[CROSS-SERVICE]` only for contracts, migrations, compatibility, or recovery behavior that genuinely spans both services.
- Name the main new or changed contracts and domain entities explicitly: endpoints, commands, events, configuration contracts, Goals, Activities, catalogs, durable records, or other first-class concepts. State whether each is added, extended, replaced, or removed.
- Explicitly retain mechanisms that materially increase implementation scope, but attach them to the contract or entity they belong to: backward compatibility, state migration, crash recovery, partial continuation, durable execution evidence, cross-component coordination, runtime-derived catalogs, native engine hooks, or separate operator recovery/reset workflows.
- Prefix every summary bullet with owner and relative implementation cost: `[CORE][LOW]`, `[JAVA][MEDIUM]`, `[CROSS-SERVICE][HIGH · RISKY]`, etc.
- Use `[LOW]` for a local/simple extension with little state, migration, or recovery impact; `[MEDIUM]` for a bounded cross-component or persistent-state change; `[HIGH]` for a new durable workflow, migration, recovery, native engine integration, or replacement of an existing execution path.
- Add `· RISKY` when correctness materially depends on migration, crash/restart recovery, idempotency, irreversible mutation, or production-only behavior.
- Rate each bullet itself, not the whole change. Cost is not code volume. Judge mechanisms by their actual role; do not treat every transaction, schema change, validation, or test as expensive. Do not estimate hours, story points, percentages, or monetary cost.
- Distinguish mechanisms being added, reused, and removed.
- Name each retained mechanism and its purpose. For material state changes, identify the owner and lifetime, including continued handling after the owning workflow completes. Omit incidental fields, classes, algorithms and individual test cases, not consequential ownership/lifecycle choices.
- State material behavior restrictions: eligibility, level/class/mode cutoffs, behavior-changing defaults or fallbacks. Preserve required resets and compatibility boundaries.
- Omit routine implementation details and ordinary tests, but explicitly name material new test-only or GM commands, endpoints, launcher flags and observation/comparison subsystems, with their purpose. Do not hide these additions behind "verification" or "runtime support".
- Do not invent requirements or hide expensive scope to meet the length target. Do not pack mini-checklists into sentences.
- If sources materially disagree about a main change or costly mechanism, state that briefly instead of silently choosing.
- For API-facing changes, always state the API surface explicitly: name the affected endpoint(s) and method(s), and say whether they are added, changed, reused unchanged, or removed. If no new endpoint is introduced, say so when the change materially extends an existing contract.

Before returning, check that an engineer can identify:
1. the affected API surface and whether endpoints are added or changed;
2. the main changed contracts and domain entities;
3. what is added, extended, replaced, or removed;
4. the costly mechanisms attached to those changes;
5. the relative implementation cost of each bullet;
6. a single clear service owner for each bullet, except genuinely cross-service work.

Output only the concise description.
