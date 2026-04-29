---
name: testery-register-environment
description: Register (create) a new Testery environment that tests can target. Use when the user wants to add a new env (e.g., "staging", "qa", "prod") to Testery.
---

# Register a Testery environment

Wraps `testery create-environment`.

```bash
testery create-environment \
  --token "$TESTERY_TOKEN" \
  --key "<env-key>" \
  --name "<Display Name>" \
  [--pipeline-stage "<stage-name>"] \
  [--variable KEY=VALUE]   # repeat; prefix `secure:` to encrypt
```

## Steps

1. Get the desired key (used in test runs) and display name.
2. Optionally collect environment variables and a pipeline stage.
3. Run the command and report the resulting environment.

To update an existing environment instead, use `testery-update-environment`.
