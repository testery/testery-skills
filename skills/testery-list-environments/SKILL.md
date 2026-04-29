---
name: testery-list-environments
description: List Testery environments, optionally filtered by pipeline stage. Use to discover environment keys before creating a test run.
---

# List Testery environments

Wraps `testery list-environments`.

```bash
testery list-environments \
  --token "$TESTERY_TOKEN" \
  [--pipeline-stage "<stage>"] \
  [--show-archived]
```
