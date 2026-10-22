---
name: investigation-rca
description: "Investigate bugs, regressions, incidents, latency, logs, metrics, and RCA with independent evidence gathering, competing hypotheses, and a root-cause completion gate."
---

### Autonomous investigation before escalation

When investigating a bug, incident, SLI/SLO degradation, metric anomaly, logs issue, dependency behavior, or code-path question, do the available research independently before asking the user for help.

Do not ask the user to fetch logs, build metric queries, inspect dashboards, search code, or collect obvious supporting data if you have tools that can reasonably do it.

If uncertainty can be reduced with available tools, investigate first. Ask only when the blocker remains after a reasonable independent attempt.

Before escalating, use the tools available for the current environment. Depending on the task, this may include:
- inspecting local code, configs, tests, and generated clients;
- searching the wider codebase with available search tools;
- checking service metadata, dependencies, consumers, and dashboards;
- querying available metrics or traversing metric hierarchies instead of guessing paths;
- using available logs, observability, MCP, CLI, or dashboard tools;
- validating hypotheses against code, metrics, logs, or runtime data when possible.

Ask the user only when there is a real blocker, such as:
- missing credentials or expired auth;
- unavailable tools or inaccessible internal systems;
- ambiguous business context that cannot be inferred from code or data;
- destructive, privileged, expensive, or production-impacting action that requires approval;
- multiple valid product decisions with different tradeoffs.

When asking the user, include:
- what you already tried;
- what evidence you found;
- why it was insufficient;
- the concrete blocker;
- the smallest input needed to continue.

Avoid:
- asking the user to check logs before trying available log tools;
- asking the user to check metrics before discovering or querying available metric paths;
- inventing metric names, paths, or dashboard filters without verification;
- stopping at a hypothesis when available tools allow validation;
- making the user do manual work that the agent can reasonably do itself.

This rule does not expand the scope of code changes. Investigation should inform the requested task, not turn into unrelated refactoring or cleanup.

### Investigation loop

For long-running debugging, RCA, SLI/SLO, latency, metrics, or incident investigations, keep moving while safe read-only next steps remain.

Treat status requests as checkpoints, not task completion, unless the user asks for status only, asks to pause, or approval is required.

At each checkpoint, maintain a compact state:
- leading hypothesis;
- evidence supporting it;
- evidence against it;
- hypotheses dropped or deprioritized and why;
- blockers and fallbacks tried;
- next read-only action;
- success criteria for the next action.

Keep checkpoint updates concise. Put detailed evidence, raw queries, long outputs, and intermediate notes in the persistent plan instead of chat.

After each evidence-gathering phase, choose the next action that most reduces uncertainty.

Stop when enough evidence supports a useful conclusion, or when no useful read-only evidence remains. For RCA, do not stop on a plausible or useful explanation: stop only when the RCA completion gate is satisfied or no useful evidence remains to test it further.

When an observability tool fails or returns partial data:

- retry once if the failure looks transient;
- try another available path such as dashboard summary, raw metric query, code-defined metric names, service metadata, logs, or saved exports;
- record the failed tool call and fallback in the persistent plan when one exists;
- continue with adjacent evidence unless the missing data is required for the next conclusion.

Before converging on a cause:

- Maintain materially plausible competing hypotheses instead of committing to the first explanation that fits.
- For the current leading hypothesis, actively look for evidence that would disprove it, not only evidence that confirms it.
- When evidence eliminates a hypothesis, record why; when evidence is insufficient, keep it explicitly unresolved.
- Finding a plausible mechanism or confirming evidence is not a stopping condition.

### Evidence trail

When making claims based on code, tests, logs, metrics, dashboards, configs, or runtime behavior, ground them in concrete evidence.

Prefer specific references over vague statements.

Include relevant evidence such as:
- file paths and function names;
- commands run and their outcomes;
- test names and results;
- metric names or dashboard paths;
- log query/filter details;
- observed vs expected values.

Avoid saying "I checked the code" or "the logs suggest" without naming what was checked.

For long-running investigations, record important evidence in the plan file when one exists.

Before trusting a detector, query, or classification rule used to distinguish normal from faulty behavior, validate it against independently known-good and known-bad cases when available. If controls fail, correct the check before relying on it; if controls are unavailable, report the validation gap.

### RCA-ready evidence

For RCA-style investigations, progressively package findings into reusable evidence blocks.

For each material claim, capture:
- claim;
- concrete evidence;
- exact metric/log query, dashboard link, file path, or command;
- interpretation in plain language;
- counter-evidence or limitations;
- next verification step.

When enough evidence exists, produce an RCA-ready summary:
- observed symptom;
- causal chain or leading root-cause hypothesis;
- confirmed non-causes;
- confidence level;
- mitigation options;
- verification or guardrail metrics.

Do not produce full RCA summaries for small local bugs unless requested.

#### RCA completion gate

Do not declare a root cause merely because one plausible explanation was found.

A root cause is established only when:

- the causal chain from the observed symptom to the proposed cause is explicit;
- every material link in that chain is supported by concrete evidence;
- the evidence distinguishes the proposed cause from reasonable competing hypotheses;
- at least one deliberate attempt was made to disprove the leading hypothesis;
- the proposed cause explains the actual observed case, not merely a behavior that could theoretically produce it;
- no unresolved upstream "why did this happen?" remains that would materially change the diagnosis.

Until these conditions are met, label the result as a hypothesis, likely cause, intermediate cause, or evidence gap — not the root cause.

### Independent investigation verification

Before finalizing a multi-step investigation, the primary agent must obtain one fresh-context, read-only subagent review, following the configured context and permission policy. Skip simple fact lookups and status-only replies. Verifiers must not delegate.

- Provide the original request, constraints, source locations, findings, evidence references, and this workflow's completion criteria. The verifier must independently inspect primary sources, not rely only on the investigator's summary.
- Have the verifier check material conclusions, omitted cases, and plausible alternatives; report the scope actually checked, evidence-backed findings, and evidence/access gaps. Do not manufacture objections.
- Wait for and process the actual review result; a timeout is not a completed review. Resolve findings using evidence, not automatic agreement, and continue permitted read-only checks without asking for routine approval.
- Allow at most one focused recheck after material corrections. If paused or genuinely blocked, report the limitation. Keep unresolved findings and unchecked scope explicit; unavailable verification or exhausted review budget does not establish correctness, and revised conclusions are not covered by an earlier review.

### Root cause before fix

Treat "root cause found" as a claim that requires proof, not as the natural conclusion of finding a plausible explanation.

For bugs, incidents, regressions, metric anomalies, or unexpected behavior, identify the likely root cause before changing code.

Do not patch symptoms without explaining why the fix addresses the underlying cause.

Before implementing a fix:
- state the observed behavior;
- state the expected behavior;
- identify the code path or system boundary where the behavior diverges;
- explain the root cause or the strongest current hypothesis;
- choose the smallest fix that addresses that cause.

When possible, add or update a regression test that would fail before the fix and pass after it.

Before considering the bug fixed, inspect relevant equivalent branches, call sites, and variants for the same defect pattern. Fix and test confirmed in-scope variants; report out-of-scope occurrences instead of expanding the task.

If the RCA completion gate is not satisfied, continue the investigation while useful read-only evidence remains. If the root cause still cannot be proven with available tools, state what evidence is missing; make a minimal mitigation or fix only when explicitly justified despite that uncertainty.
