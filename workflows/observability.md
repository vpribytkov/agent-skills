# Runtime diagnostics

Use when a change needs rollout visibility or runtime diagnosis. Start with a
concrete question operators need to answer, then inspect existing metrics, logs,
and traces. Add instrumentation only for a material unanswered question.

## Choose the signal

- For a changed business flow, identify which outcomes matter: attempts, success, failure, or relevant skips, retries, deduplication, and rollback. Existing signals may already cover them.
- For performance or dependencies, use duration, latency, throughput, lag, or failure signals that address the actual risk. Error-only data cannot establish successful rollout volume.
- Reuse existing clients, helpers, metric families, names, and label conventions. Do not add a metric that can be reliably derived from existing ones.
- Use counters for events, histograms/timers for duration, and gauges for current state that rises and falls.

## Ownership and dimensions

Measure an event where it occurs: `service` for business outcomes, `storage` for
DB operations, `client` for external calls, and `cron`/runtime for job lifecycle.
Avoid duplicating a dependency's metric in its caller.

Follow repository naming. Where the dotted convention is used, preserve
`<layer>.<component>.<operation>.<result>`, for example
`service.padme_sync.rows.success` or
`storage.personal_data.acquire_padme_sync_batch.error`.

Keep metric labels bounded, such as operation, result, reason, or task type.
Do not use raw IDs or error strings as metric labels. Use established, non-sensitive
correlation fields for logs and traces; never include secrets or raw personal data.

## Keep diagnostics useful

- Use structured logs for actionable events and traces for flow or latency questions. Avoid noisy repetition, especially in retries and batch loops.
- Add or recommend dashboards and alerts only when needed for a concrete operational question or requirement.
- Verify returned results, errors, persistence, retry/rollback behavior, and side effects directly. Do not add diagnostic log/metric assertions, recorders, or collectors unless the user requests them.
- Diagnostic-only changes do not need new tests. Preserve existing diagnostic tests outside the task scope.
- Report material diagnostic gaps that limit rollout or investigation. There is no requirement to add instrumentation or explain its absence for every runtime change.
