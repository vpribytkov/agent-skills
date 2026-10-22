---
name: codegraph
description: "Navigate symbols, callers, callees, dependency impact, and execution paths using an existing CodeGraph index before broad textual searches."
---

## CodeGraph

Use an existing CodeGraph index and available `codegraph_*` MCP tools for structural navigation. Do not assume every repository or machine has CodeGraph configured. Index results help locate code; they are not proof of current runtime behavior.

### When to prefer codegraph over native search

Use codegraph for **structural** questions — what calls what, what would break, where is X defined, what is X's signature. Use native grep/read only for **literal text** queries (string contents, comments, log messages) or after you already have a specific file open.

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "How does X reach/become Y? / trace the flow from X to Y" | `codegraph_trace` |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

### Rules of thumb

- **Answer directly — don't delegate exploration.** For "how does X work" / architecture questions, answer with 2-3 codegraph calls: `codegraph_context` first, then ONE `codegraph_explore` for the source of the symbols it surfaces. For a specific **flow** ("how does X reach Y") start with `codegraph_trace` from→to then ONE `codegraph_explore` for the bodies; don't rebuild the path with `codegraph_search` + `codegraph_callers`. Codegraph IS the pre-built index, so spawning a separate file-reading sub-task/agent — or running a grep + read loop — repeats work codegraph already did and costs more for the same answer.
- **Avoid redundant search, not verification.** Do not repeat the same symbol lookup with grep. Inspect the relevant current source and diff to verify implementation, uncommitted changes, and material claims; use runtime evidence when the claim is about runtime behavior.
- **Don't grep first** when looking up a symbol by name. `codegraph_search` is faster and returns kind + location + signature in one call.
- **Don't chain `codegraph_search` + `codegraph_node`** when you just want context — `codegraph_context` is one call.
- **Don't loop `codegraph_node` over many symbols** — one `codegraph_explore` call returns several symbols' source grouped in a single capped call, while each separate node/Read call re-reads the whole context and costs far more.
- **Index lag — check the staleness banner, don't guess a wait.** When a codegraph response starts with "⚠️ Some files referenced below were edited since the last index sync…", the listed files are pending re-index — Read those specific files for accurate content. Absence from the banner does not replace targeted current-file/diff verification when correctness depends on it. `codegraph_status` also lists pending files under "Pending sync".

### Availability and installed CLI

If `.codegraph/` is absent, skip CodeGraph and use focused native search/read. Do not propose or run index creation as a prerequisite to an unrelated task. Initialize it only when the user explicitly requests setup.

Prefer MCP; when unavailable on Windows, use the known per-user installation:

```powershell
& "$env:LOCALAPPDATA\codegraph\current\bin\codegraph.cmd" explore '<symbols or question>'
```

Use an explicitly configured machine-local path when it differs. Do not probe PATH, search for installs, download, or reinstall CodeGraph. If the known CLI is unavailable, report the limitation and continue with focused native inspection. Request `sandbox_permissions="require_escalated"` when required by the configured Windows runtime and allowed by its approval policy; never bypass permissions.
