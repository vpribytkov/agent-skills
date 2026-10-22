# Global instruction migration

One shared `instructions/AGENTS.md` replaces the work and home global files.
The baseline includes the previously agreed writing edits, not the old instruction
to sacrifice grammar. The uploaded originals are not committed; private examples
and machine-specific usernames are not part of this public repository.

## Global rule inventory

Each row identifies the source rule or a duplicate pair and its destination.
Work and home refer to the two supplied global files, including the agreed
Communication revisions. "Merged" does not mean the weaker variant was selected.

| Source rule | Destination | Treatment |
|---|---|---|
| Work: emoji starter | Communication | Retained. |
| Both: Understand the Intent | Core Principles | Shared rule retained. |
| Both: Independent Judgment | Core Principles | Shared rule retained, including no manufactured disagreement. |
| Both: Stay Focused on the Intent | Core Principles | Shared scope boundary retained. |
| Work: ownership of investigation, implementation, verification, recovery; home: discover facts independently, continue until blocked | End-to-End Ownership | Combined, within authorized scope. |
| Work: reuse existing/native solutions; home: reject speculative complexity | Simplicity First | Both requirements retained. |
| Both: smallest relevant changes; home: preserve user changes and avoid reformatting | Surgical Changes | Combined. |
| Work: behavior, tests, callers, data flow, config, risks; home: root cause before edits | Think Before Coding | Combined. |
| Work: materially distinct behavior variants | Core Principles | Retained outside Communication, as previously agreed. |
| Both: define proof, behavioral contracts, focused checks | Goal-Driven Execution | Combined; intentional behavior changes remain an exception. |
| Both: try to falsify material correctness/completeness claims | Core Principles | One copy retained. |
| Work: verify real artifacts/results, rerun on final tree | Core Principles | Retained. |
| Work: confirm tests ran, distinguish failed/skipped/not-run/unknown | Core Principles | Retained. |
| Work: independent test expectations, no configuration mirroring | Core Principles | Retained. |
| Both: mandatory coding-quality, subject to requirements/project scope | Core Principles | Shared rule retained. |
| Home: diagnosis/review does not authorize writes | Guardrails | Retained. |
| Home: ask only for missing authority/access or material decisions | Guardrails | Retained. |
| Home: no destructive operations against broad/unresolved targets | Guardrails | Retained. |
| Home: commits/branches/pushes/PRs/releases/deployments need authority | Guardrails | Retained. |
| Home: protect secrets and sensitive data | Guardrails | Retained. |
| Both: CodeGraph structural-first; home: known CLI, no install search, current diff verification, skip unindexed repos | Tooling + codegraph | Combined; conflicts resolved below. |
| Home: installed OpenSpec command, strict validation syntax, no reinstall | Tooling + openspec-conventions | Retained; per-user environment paths replace a fixed username. |
| Work: compact Avito commands | Tooling | Retained only for repositories using that CLI. |
| Work: recover Go vendor mismatch | Tooling | Retained only for authorized dependency-file changes. |
| Both: focused reads, bounded batches; work: stat/name-only and small diff context | Tooling + Context Economy | Combined without duplicate batching rules. |
| Both: minimum evidence and no unnecessary investigation expansion | Context Economy | Combined; targeted sampling and sufficient-evidence stop retained. |
| Home: account for replay cost, avoid micro-probes/polling, separate dependent checks | Context Economy | Retained. |
| Both: explicit fork_turns; none default; 3 only when needed; no all/omission; self-contained task; ask above three subagents | Subagent context policy | All five rules retained. |
| Work: root AGENTS, otherwise CLAUDE, project precedence | Workflows | Retained; directory-scoped instructions acknowledged. |
| Work: conditional planning/RCA/integration/observability/OpenSpec routes | Workflows + Tooling | Paths replaced by skill names. |
| Work: PR legacy route and create-pr route | Workflows | Consolidated to existing create-pr, per prior decision. |
| Work: load routed files only when relevant | Workflows | Retained for routed skills. |
| Both: natural Russian; outcome first; explicit actor; complete sentences; consistent terms; explain jargon; examples | Communication | Uses the agreed revised home wording. |
| Home: concrete evidence and human-readable prose | Communication | Retained. |
| Home: investigation finding/evidence/uncertainty/next action | Communication | Retained. |
| Home: completed code changes/checks/material risks | Communication | Retained. |
| Home: meaningful updates only, observable progress rather than internal action logs | Communication | Retained. |
| Old files: sacrifice grammar for brevity; duplicate Tooling heading | None | Removed in the already agreed writing revision, not a new policy change. |

## Additional instruction files

| Uploaded source | Installed destination | Preserved content / changes |
|---|---|---|
| `planning.md` | `skills/planning/SKILL.md` | Atomic step fields, plan before edits, per-file mapping, progress/review state, persistent plan location/date, hypotheses/evidence, self-review and final reporting retained. Private code examples generalized. Existing adequate workflow plans can be reused; detailed file lists stay linked from the concise final report. |
| `investigation-rca.md` | `skills/investigation-rca/SKILL.md` | Body retained unchanged: autonomous research, escalation criteria, investigation loop/fallbacks, competing hypotheses, evidence/control checks, RCA gate, fresh-context review and focused recheck, root cause before fix and equivalent-branch check. |
| `integration-tests.md` | `skills/integration-tests/SKILL.md` | Table cases, visible expectations, DB/public assertions, fixture ownership, limited mocks, generation, nearby patterns, focused execution, service-level risk coverage retained. Business-specific example names generalized; generator examples apply only in projects that use them. |
| `observability.md` | `skills/observability/SKILL.md` | Readiness decision, success/failure/skip volume, bounded dimensions, business/technical metrics, ownership, no redundant metrics, logs/traces, sensitive data, dashboard/alert follow-up and testing rules retained. Private metric examples generalized; naming follows the established project convention. |
| `frontend.md` | `skills/frontend/SKILL.md` | Audience/design-system guidance, domain-specific UI, controls/icons, layout/type/color constraints, assets/3D checks, existing game engines and dev-server handoff retained. Explicit scope boundary added; this is not permission to invent product scope. |
| `openspec.md` | `skills/openspec-conventions/SKILL.md` | Jira-only naming, one change per affected service, unknown-value clarification, durable capability naming and service selection retained. Adds the home installed-command rule. Internal issue/service examples replaced by generic examples. |
| `codegraph.md` | `skills/codegraph/SKILL.md` | Structural tool table, bounded context/explore/trace navigation, no redundant symbol searches, batched source retrieval and stale-index checks retained. Availability, evidence and setup conflicts resolved below. |
| `pr.md` | Existing `skills/create-pr/SKILL.md` | No second PR authoring source. Existing skill is unchanged and keeps Russian reviewer-oriented descriptions, task title/identifier when known, and conditional related-PR section. Jira-only titles and mandatory empty related-change sections are deliberately not restored. |

## Explicit conflict resolutions

1. **CodeGraph is navigation, not proof.** The uploaded tool guide prohibited
   verification with grep and asserted completeness/freshness too strongly. The
   home global file instead required relevant current-source/diff checks. Preserve
   the latter while avoiding duplicate symbol searches. No new indexing is proposed
   for an unrelated task when `.codegraph/` is absent. An unavailable known CLI is
   reported and focused native inspection remains available; no installation hunt.
2. **Read-only means no vendoring mutation.** Automatic `go mod vendor` is limited
   to authorized changes and repository policy. In diagnosis/review, report the
   mismatch instead of modifying dependencies.
3. **One source of PR rules.** Use the already agreed, tracker-independent
   `create-pr` skill; do not revive the obsolete uploaded Jira-only document.
4. **Concise communication and full planning evidence coexist.** The full atomic
   plan and detailed file/self-review records remain persistent. Chat contains a
   concise plan and final summary with a link to that evidence. Reuse an adequate
   active workflow plan rather than create a competing one.
5. **Portable does not mean universally installed.** Derive known Windows tool
   paths from `LOCALAPPDATA` / `APPDATA`, allow explicitly configured machine-local
   paths, and keep sandbox approval requirements. Avito and Jira conventions are
   conditional. The installer does not install those tools, change permissions,
   or persist machine credentials.
6. **Metric ownership is shared; spelling follows the project.** The dotted naming
   scheme remains the recommendation for dotted-name repositories, not a mandate
   to replace another established convention.

The migration does not alter existing factory/OpenSpec execution skills, create
work/home profiles, generate AGENTS from fragments, or add automatic background
Git synchronization. Test evidence belongs in PR comments, not the PR description.
