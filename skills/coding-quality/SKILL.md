---
name: coding-quality
description: >
  Use when the user requests a focused code design, readability, or complexity
  review, or explicitly invokes coding-quality. Optional reference for simplifying
  an implementation; do not load for every code change.
---

# Coding Quality

<!-- Copyright (c) 2026 DietrichGebert (MIT). -->

Review the requested behavior and affected code. Follow explicit requirements,
repository rules, and compatible local patterns before this guidance.

## Design

- Prefer existing code, standard libraries, platform features, and installed dependencies. Add an abstraction only when it removes relevant complexity now.
- Keep the diff limited to the requested behavior and the callers, fixtures, and tests needed to make it work. Do not turn a local fix into a redesign.
- Keep domain decisions and state transitions readable together. Extract mechanics when they obscure a decision, not to meet function-size or complexity limits.
- Preserve distinct outcomes when callers care about them. Use separate branches for different decisions; keep compound conditions that express one decision.
- Name domain actions and outcomes clearly. Comment reasons or limitations the code cannot express; do not add helpers that merely hide syntax.
- Preserve validation at trust boundaries and meaningful error causes. Reuse established error handling; do not silently turn failure into unrelated fallback behavior.

## Configuration and verification

- Validate configuration structure and invariants rather than hardcoding the currently committed values. A valid alternative configuration should work without an implementation change.
- Derive test expectations from requirements and observable behavior. Do not copy implementation constants or configuration tables unless their exact contents are the contract.
- Check materially different affected paths, including failure or no-op outcomes where relevant. Keep expected domain results visible; use helpers for plumbing.
- Reuse the narrowest meaningful checks. Do not add a test or self-check solely because this skill was loaded.

## Review findings

Report actionable problems that affect correctness or make the requested behavior
hard to understand or verify. Explain the consequence and the smallest useful
change. Avoid stylistic churn, speculative flexibility, and unrelated cleanup.
State the scope actually inspected and any material verification gap.
