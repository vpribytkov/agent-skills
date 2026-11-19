---
name: openspec-summarize-change
description: "Use when asked for a concise technical summary of a specification or OpenSpec change, preserving ownership, costly mechanisms and relative implementation cost."
---

# OpenSpec Summarize Change

Read the supplied specification and available proposal, requirements, design and tasks. Describe the requested change, not implementation status. Do not launch review or apply.

Return only up to five concise bullets in the user's language. Prefer 40–60 words overall, but retain material contracts, ownership and lifecycle decisions even when more words are needed. Each bullet covers one coherent change.

## Content

- Prefix with the actual service/component owner and relative cost: `[<owner>][LOW]`, `[<owner>][MEDIUM]` or `[<owner>][HIGH · RISKY]`. Keep one owner per bullet; use `[CROSS-SERVICE]` only for genuinely shared contracts, migrations or recovery. Do not invent service boundaries.
- Name the main contracts and domain entities, and whether they are added, extended, replaced, reused or removed. For APIs, name methods/endpoints and whether each is new, changed, unchanged or removed; say when an existing contract expands without a new endpoint.
- Attach costly mechanisms to their contract and purpose: compatibility, migration, crash recovery, continuation, durable evidence, coordination, runtime-derived catalogs, external hooks or separate operator recovery/reset workflows. Distinguish adding a mechanism from reusing or removing it.
- Preserve consequential state ownership and lifetime, including behavior after the owning workflow completes. State eligibility/mode restrictions, behavior-changing defaults/fallbacks, required resets and compatibility boundaries.
- Name substantial new testing/operator commands, endpoints, launcher flags or observation/comparison systems and their purpose; do not hide them behind “verification” or “runtime support”. Omit routine tests, fields, classes and incidental algorithms.
- State material source contradictions instead of silently choosing. Do not add requirements or hide expensive scope to meet the length preference.

## Cost labels

- `LOW`: local/simple extension with little state, migration or recovery impact.
- `MEDIUM`: bounded cross-component or persistent-state change.
- `HIGH`: new durable workflow, migration, recovery, external runtime integration or replacement of an execution path.
- Add `· RISKY` when correctness materially depends on migration, crash/restart recovery, idempotency, irreversible mutation or production-only behavior.

Rate each bullet's actual mechanisms, not code volume; ordinary transactions, schema changes or tests are not automatically expensive. Do not estimate hours, story points, percentages or money.
Before returning, check that the affected API/contracts, change direction, costly mechanisms, owner and per-bullet cost remain visible.
