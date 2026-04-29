---
name: testery-create-test-run
description: Submit a Git-based test run to Testery. Use when the user asks to "run tests on Testery", "kick off a Testery run", "trigger a test run for branch X", etc.
---

# Create a Testery test run

Wraps `testery create-test-run`. Submits a test run for a given project + environment, optionally pinned to a Git ref/branch or a previously-uploaded build.

## Required inputs

- `--project-key`: project key in Testery.
- `--environment-key`: environment key the tests run against.
- One of: `--git-ref <sha>`, `--git-branch <name>`, `--build-id <id>` (with prior `upload-build-artifacts`), or `--latest-deploy`.

## Common optional flags

- `--include-tags a,b,c` / `--exclude-tags x,y`: filter scenarios by tag.
- `--test-filter-regex <pattern>`: regex test filter (repeatable).
- `--parallelize-by-file` or `--parallelize-by-test`.
- `--runner-count <N>`: parallel runners.
- `--copies <N>`: submit multiple copies.
- `--variable KEY=VALUE`: env variable for this run (repeatable; prefix `secure:` to encrypt).
- `--timeout-minutes <N>` / `--test-timeout-seconds <N>`.
- `--wait-for-results`: block until completion (combine with `--fail-on-failure` for CI).
- `--output pretty|json|teamcity`.
- `--test-suite "Name"`: run a saved test suite.

## Template

```bash
testery create-test-run \
  --token "$TESTERY_TOKEN" \
  --project-key "<project>" \
  --environment-key "<env>" \
  --git-branch "<branch>" \
  [--include-tags ...] [--runner-count N] [--wait-for-results --fail-on-failure]
```

## Steps

1. If you don't know the project/environment keys, ask the user, or use the Testery MCP `list_projects` / list environments via `testery list-environments`.
2. Build the command above with the user's inputs.
3. Run it and report `test_run_id` from the output.
4. If the user wants to follow it, use the `testery-monitor-test-run` skill.
