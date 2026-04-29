---
name: testery-update-environment
description: Update an existing Testery environment (rename, change pipeline stage, set/replace variables). Use when modifying an env that already exists.
---

# Update a Testery environment

Wraps `testery update-environment`.

```bash
testery update-environment \
  --token "$TESTERY_TOKEN" \
  --key "<env-key>" \
  [--name "<New Name>"] \
  [--pipeline-stage "<stage>"] \
  [--variable KEY=VALUE] \
  [--create-if-not-exists]
```

Pass `--create-if-not-exists` to upsert (create when the key isn't found).
