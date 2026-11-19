# Investigation and root cause analysis

Use for bugs, regressions, incidents, latency, or unexpected runtime behavior.
Keep the investigation proportional to the question and the consequence of error.

## Gather decisive evidence

- Establish observed versus expected behavior and the affected path, inputs, variants, and time window. Start at the boundary where they diverge.
- Use available code, tests, configuration, logs, metrics, and service metadata before asking the user to collect them. Discover actual metric names and query filters instead of guessing.
- Choose the next check that distinguishes plausible causes. Look for evidence against the leading hypothesis as well as evidence supporting it.
- Validate a detector, query, or classification rule against independently known-good and known-bad cases when available. If controls are absent or fail, state the limitation before relying on it.
- When a tool fails or data is partial, try a useful retry or alternative source. Ask only for the access, authority, or business decision still needed; explain what was tried and the concrete gap.
- Keep important evidence traceable to a command, test, file/function, query, or dashboard and its observed result. Persist state only when continuity needs it; reuse the task record.

## Match conclusions to evidence

Call a finding a root cause only when the evidence supports the causal chain for
the actual observed case and distinguishes it from reasonable alternatives.
A mechanism that could produce the symptom is still a hypothesis. State any
unresolved cause or upstream uncertainty that would materially change the diagnosis.

For a requested RCA, explain the symptom, supported causal chain, relevant
counter-evidence, remaining uncertainty, and mitigation or verification options.
A local bug does not need a full incident report. Stop when the requested conclusion
is supported or further useful evidence is unavailable; make any limit explicit.

## Fix the demonstrated failure

- Explain how the smallest fix addresses the cause or why a mitigation is justified despite uncertainty. Stay within the authorized scope.
- Check relevant equivalent branches and call sites for the same defect; fix confirmed in-scope occurrences, and report material occurrences outside scope.
- Use a regression check that distinguishes broken from expected behavior when practical. Verify the corrected observable outcome, not just successful execution of the tool.
- Report what is confirmed, what remains a hypothesis, what actually ran, and any remaining action. Do not equate unavailable, skipped, or failed checks with a pass.
