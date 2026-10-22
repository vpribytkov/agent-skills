### Task planning and progress tracking

For any coding or investigation task, create a proportional plan before substantial work.

For coding tasks, create the plan before editing code.

For trivial one-step tasks, the plan may be a single concise sentence.

For multi-step, multi-file, refactoring, validation, debugging, RCA, metrics, or test-related work, use an atomic task plan.

The plan must be optimized for human review.

Each atomic step should be small enough that the user can review it independently.

Each atomic step must include:
- step number;
- step title;
- purpose: why this step exists;
- what to do: the concrete change or investigation action;
- expected files, systems, or tools involved;
- behavior, contract, or hypothesis affected;
- verification for this step;
- simplification check: whether this step can reuse existing behavior, configuration, standard library, platform/framework code, or an already-installed dependency instead of adding custom code.

For coding tasks, use exact file paths when known. Use broad globs only during initial discovery, then refine the plan to exact files before editing.

Avoid vague plan steps such as:
- "fix validation behavior";
- "update tests";
- "clean up related code";
- "adjust service logic".

Prefer reviewable steps such as:
- "change `ConditionPathExists` to collect up to 10 missing category paths";
- "add unit cases for multi-error `ConditionPathExists` behavior";
- "update `archive_old_entities` to construct `ExperimentGenerationValidator` through `New(...)`";
- "replace zero-value validator construction in remaining `cmd/**/main.go` entrypoints".

For coding tasks, every changed file must map back to a plan step. If implementation needs to touch a file not covered by the plan, update the plan before changing it.

If a broad step starts touching multiple independent behaviors, split it into smaller steps before continuing.

For investigation tasks, keep the current hypothesis, evidence, blockers, and next action explicit.

Show the plan in chat before implementation or investigation work, but do not wait for approval unless the user explicitly asked for approval, or unless the plan depends on unresolved product judgment.

For multi-step work:
- implement or investigate step by step;
- update the plan status as work progresses;
- mark completed steps;
- record files changed for coding steps;
- record verification performed;
- record issues found during self-review;
- record follow-up changes made after self-review.

If the user reviews or approves only part of the plan, preserve that review state and continue from the next unreviewed step unless asked to pause.

Use a persistent task plan file when the task is multi-step, multi-file, long-running, investigation-heavy, or when context loss would hurt continuity.

The persistent task plan should preserve both:
- the original atomic implementation/review plan;
- the current progress state.

When a persistent task plan is needed:
- use the active harness global configuration directory already resolved as `<agent-root>`;
- create the plan under `<agent-root>/plans/<repo-name>/`;
- use the repository root directory name as `<repo-name>`;
- use a clear task-specific filename with the plan creation date (`YYYYMMDD` format) as a prefix:
  - `<agent-root>/plans/<repo-name>/YYYYMMDD-<short-task-name>-progress.md`
- keep the original date prefix unchanged if work on the same plan continues across multiple days;
- use lowercase kebab-case for `<short-task-name>`;
- keep a `Next action` section current;
- record completed steps, files changed, discovered facts, rejected hypotheses, blockers, verification commands, metric/log queries, and relevant links;
- keep it current enough that another engineer can continue the task without needing the conversation history.

Before final response:
- self-review the work against the plan;
- update the plan with fixes made during self-review;
- ensure every changed file or major investigation claim maps back to a plan step;
- mention any implementation drift from the original plan.

The final response must include:
- implementation steps completed;
- files changed per step;
- verification performed;
- self-review fixes made;
- remaining risks or follow-ups.

Do not keep important long-running task state only in chat or only in an internal todo list.