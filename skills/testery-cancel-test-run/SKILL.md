---
name: testery-cancel-test-run
description: Cancel a running Testery test run by ID. Use when the user asks to "stop", "abort", or "cancel" a Testery run.
---

# Cancel a Testery test run

Wraps `testery cancel-test-run`.

```bash
testery cancel-test-run \
  --token "$TESTERY_TOKEN" \
  --test-run-id <id>
```

## Steps

1. Confirm the test run ID with the user (cancellation is destructive).
2. Run the command and report the result.
