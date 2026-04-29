---
name: testery-deregister-environment
description: Delete (deregister) a Testery environment by key. Use when the user wants to remove an environment from Testery.
---

# Deregister a Testery environment

Wraps `testery delete-environment`.

```bash
testery delete-environment \
  --token "$TESTERY_TOKEN" \
  --key "<env-key>"
```

## Steps

1. Confirm with the user: deletion is destructive.
2. Run the command.
