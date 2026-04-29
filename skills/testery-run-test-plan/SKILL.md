---
name: testery-run-test-plan
description: Execute a saved Testery test plan against an environment. Use when the user references running a "test plan" (a curated set of suites/projects).
---

# Run a Testery test plan

Wraps `testery run-test-plan`.

```bash
testery run-test-plan \
  --token "$TESTERY_TOKEN" \
  --test-plan-key "<plan-key>" \
  --environment-key "<env-key>" \
  [--variable KEY=VALUE]
```
