---
name: testery-list-active-test-runs
description: List currently-active Testery test runs and their status. Use when the user asks "what's running?" or wants an overview of in-flight runs.
---

# List active test runs

Wraps `testery list-active-test-runs`.

```bash
testery list-active-test-runs \
  --token "$TESTERY_TOKEN" \
  [--output pretty|json]
```

For richer read-only inspection (per-project listing, completed runs, results) the Testery MCP server's `list_test_runs` and `get_test_results` tools are a good alternative when configured.
