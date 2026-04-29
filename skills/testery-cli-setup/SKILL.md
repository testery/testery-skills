---
name: testery-cli-setup
description: Verify the Testery CLI is installed and authenticated. Use before invoking any other testery-* skill if auth has not been confirmed in the current session.
---

# Testery CLI setup

Every other `testery-*` skill in this collection shells out to the `testery` CLI. This skill confirms the CLI is on PATH and the API token is valid.

## Required environment

- `TESTERY_TOKEN`: your Testery API token (set as env var, or pass `--token <value>` to each command).
- `TESTERY_DEV=1` (optional): target the dev API instead of production. When set, also pass `--testery-dev` to CLI commands.

If the user has never set up Testery on this machine, prefer the `testery-onboard` skill: it handles signup/login on testery.io, captures the API key, and persists it to `~/.testery/credentials` and the shell rc so it survives across sessions.

Token resolution order used by skills in this collection:
1. `$TESTERY_TOKEN` env var
2. `~/.testery/credentials` (single line: `TESTERY_TOKEN=<token>`)
3. Explicit `--token` flag

## Steps

1. Check the CLI is installed:
   ```bash
   testery --help
   ```
   If missing, install: `pip install testery` (or `pip install -e <path-to-testery-cli>`).

2. Verify the token:
   ```bash
   testery verify-token --token "$TESTERY_TOKEN"
   ```

3. If verification fails, ask the user to set `TESTERY_TOKEN` from their Testery account profile.

## Notes

- The CLI source of truth is `testery.py` in the `testery-cli` repo: pass `--help` to any subcommand for full options.
- For read-only inspection (list projects/runs/results), the Testery MCP server can be used instead when configured.
