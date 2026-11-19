---
name: openspec-review-change
description: "Use when explicitly asked to review an OpenSpec plan before implementation, or resolve a concrete concern about its scope, design or acceptance. Not a mandatory planning gate."
---

# OpenSpec Review Change

Review the requested change without editing artifacts or starting apply unless asked.
Read the source request and approved decisions/Resolved Intent first: they bound scope even when planning artifacts agree with each other. Then read the change's available proposal, delta specs, design and tasks using its native OpenSpec workflow/schema. Inspect base specs and affected code when needed to validate changes or material design assumptions.

## Review

- Check for wrong behavior, hidden scope, contradictory requirements, missing consequential decisions, blocked execution or weak acceptance. Do not invent requirements to justify existing planning machinery.
- Requirements must describe observable behavior, with meaningful scenarios and correct `ADDED` / `MODIFIED` / `REMOVED` semantics relative to base specs. Check material variants and failure behavior where relevant.
- Validate material design assumptions against the affected system and project rules, not just other artifacts. Keep unsupported assumptions explicit.
- Challenge compatibility, migration, recovery, versioning or durable-state machinery that lacks an accepted requirement. When its cost rivals the feature, raise the simpler operational alternative for an owner decision; preserve explicit compatibility and safety obligations.
- Tasks should deliver coherent, verifiable behavior with known dependencies and enough context to execute or resume. Split tooling development from production acceptance when combining them prevents independent verification; do not mandate a preferred decomposition without a concrete consequence.
- Prove behavior at the cheapest authoritative layer. Avoid duplicate variant matrices unless each layer can independently break the contract. Require real runtime proof only for runtime/external-service semantics, early enough to resolve major implementation risk.

## Severity

Use `BLOCKER` only for a concrete failure that requires changing the artifacts before a competent implementer can safely complete and verify the intended outcome. Examples include a broken primary path, conflicting accepted decisions, missing material product/architecture choices, data loss, identity corruption, duplicate mutation or false acceptance.
Convenience recovery, wording, preferred task order, extra tests and implementation choices within existing invariants are not blockers. A rare failure with a contained, conservative outcome is not a blocker merely because it is possible; destructive or core-safety violations still can be.
Use `WARNING` only for a realistic, material apply risk. Omit speculative issues and unrelated improvements; prefer `READY` when the evidence supports it.

## Return

1. Verdict: `READY`, `READY WITH CHANGES` or `NOT READY`, with a short reason.
2. Material findings in impact order: stable `B1`/`W1` identifiers, artifact/section, concrete failure and minimal correction. Preserve identifiers across review rounds.
3. Owner decisions only when product/scope judgment is genuinely required; state material evidence gaps.

If no material findings remain, return `READY` with a short reason. Do not launch a summary, implementation or another review automatically.
