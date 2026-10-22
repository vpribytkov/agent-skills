---
name: observability
description: "Assess and implement metrics, structured logs, and traces for runtime behavior changes, async work, integrations, error paths, and production readiness."
---

# Observability workflow

Use this workflow for production behavior changes, async jobs, integrations, validation/rejection flows, data imports/exports, retries, error-path changes, and any code path whose runtime behavior must be understood after deployment.

Observability is part of implementation readiness, not an optional follow-up.

## Observability decision

Before finishing a runtime behavior change, decide whether the change needs:
- business metrics;
- technical metrics;
- structured logs;
- tracing/span attributes;
- dashboard or alert follow-up.

Do not add observability blindly. Add it when it answers a concrete production question.

If observability is not added, state why in the final response.

Observability is sufficient only when it answers the concrete rollout/debug questions introduced by the change.

Before marking observability as sufficient, explicitly answer:

- How can operators tell that the new behavior is active?
- How many relevant attempts happened?
- How many succeeded?
- How many failed?
- How many were skipped, rejected, retried, deduplicated, or rolled back when applicable?
- Which bounded dimensions matter for debugging or rollout safety?
- Which existing or new metrics/logs/traces answer these questions?

Error-only observability is not sufficient by default for production-impacting behavior unless successful activity or rollout volume is observable elsewhere and cited.

If these questions cannot be answered by existing or newly added observability, the change is not production-ready.

## Business metrics

Business metrics describe what happened in the domain operation.

Add or update business metrics when the change affects:

- a business operation;
- validation or rejection flow;
- task/job lifecycle;
- data import/export;
- entity creation/update/delete;
- replication, cloning, migration, sync, or generation flow;
- user-visible or product-visible outcome.

Business metrics should answer:

- How many operations were attempted?
- How many succeeded?
- How many failed?
- How many were skipped, rejected, retried, rolled back, or deduplicated?
- Why was work skipped or rejected?
- Which business branch/path was used?
- Is the new behavior replacing the old behavior as expected?

Prefer counters with bounded labels such as:

- operation;
- result;
- reason;
- task_type;
- source;
- status.

Avoid high-cardinality labels such as raw IDs, user IDs, record keys, emails, request IDs, or unbounded error strings.

## Technical metrics

Technical metrics describe how the system performed.

Add or update technical metrics when the change affects:

- external dependency calls;
- repository/database calls;
- queues, consumers, workers, crons, or async jobs;
- retries, timeouts, fallbacks, or circuit-breaker-like behavior;
- latency-sensitive code;
- batch size, lag, throughput, or processing duration.

Technical metrics should answer:

- How long did the operation take?
- Which dependency failed?
- How often did retries happen?
- How often did fallback behavior happen?
- How many items were processed per batch?
- Is latency, throughput, lag, or error rate changing?

Use:

- counters for attempts, successes, failures, retries, skips, fallbacks;
- histograms/timers for duration and latency;
- gauges only for current state values that go up and down.

Avoid derived or redundant metrics. If a value can be reliably derived from existing metrics, prefer not to add a separate metric.

For example, if both `service.record_sync.rows.success` and `service.record_sync.rows.failed` exist, then a separate batch-size metric is usually unnecessary because processed batch size is `rows.success + rows.failed`.

Add a separate metric only when it answers a different production question or avoids an expensive calculation/query.

## Existing pattern first

Before adding metrics/logs/traces:

1. Inspect nearby code for existing observability patterns.
2. Reuse existing metric clients, names, labels, and helpers.
3. Prefer extending an existing metric family when it matches the same domain concept.
4. Do not invent a new naming or label style unless the existing pattern is clearly unsuitable.

## Metric ownership and naming

Before adding a metric, decide which layer owns the measured event:

- `service` — business outcome of a service-level flow;
- `storage` — database/repository operation result;
- `client` — external dependency call result;
- `cron`/runtime — job execution lifecycle, duration, and run status.

Place the metric at the layer where the measured operation actually happens. Do not expose storage or client operation metrics from a service just because the service calls that dependency.

Use this naming pattern: `<layer>.<component>.<operation>.<result>`.

Examples:

- `service.record_sync.rows.success`
- `service.record_sync.rows.failed`
- `storage.records.acquire_record_sync_batch.success`
- `storage.records.acquire_record_sync_batch.error`
- `storage.records.mark_record_synced.success`
- `storage.records.mark_record_synced.error`

A service-level metric should describe the business/process outcome. A storage-level metric should describe the DB operation outcome. A client-level metric should describe the external call outcome.

Avoid metrics that only duplicate another layer's responsibility.

## Logs and traces

Use structured logs for specific diagnostic events:

- unexpected state;
- rejected/skipped work;
- external dependency failure;
- retry exhaustion;
- fallback selection;
- irreversible or hard-to-reconstruct decisions.

Use traces/span attributes for request flow, async processing, cross-service calls, or latency-sensitive paths.

Do not log or tag secrets, credentials, tokens, personal data, raw sensitive values, or high-cardinality identifiers.

## Dashboard and alert follow-up

Do not create dashboards or alerts by default.

Mention dashboard or alert follow-up when:

- a new critical metric is introduced;
- the change affects SLO/NFR, latency, availability, error rate, throughput, lag, or data freshness;
- operators need rollout visibility.

## Testing observability

Do not assert metric calls in ordinary unit tests for business logic.

Unit tests should verify observable behavior:

- returned errors;
- dependency calls;
- retry/continue/rollback semantics;
- skipped side effects;
- persistence or external-boundary behavior.

Test metric calls only when metric selection or aggregation is itself non-trivial logic.

For simple counters, prefer production code clarity over brittle mock expectations.

## Final check

Before finishing, verify:

- business metrics were considered;
- technical metrics were considered;
- added labels are low-cardinality and non-sensitive;
- existing observability patterns were followed;
- logs/traces are not noisy or sensitive;
- final response says what observability was added or why none was added.
