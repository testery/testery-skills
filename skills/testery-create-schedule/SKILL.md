---
name: testery-create-schedule
description: Create a Testery schedule that triggers test runs on a cron, on deploy, or following another run. Use when the user wants to "schedule tests", "run nightly", "trigger on deploy", etc.
---

# Create a Testery schedule

Wraps `testery create-schedule`. Schedules can fire on cron, on a deploy event, or as a follow-up to another run.

## Common shapes

Cron:
```bash
testery create-schedule \
  --token "$TESTERY_TOKEN" \
  --schedule-name "<name>" \
  --project-key "<project>" \
  --environment-key "<env>" \
  --schedule-type CRON --cron "0 2 * * *" \
  [--git-branch main] [--include-tags @smoke] \
  [--runner-count 4] [--retry-failed-tests]
```

On deploy:
```bash
testery create-schedule \
  --token "$TESTERY_TOKEN" \
  --schedule-name "<name>" \
  --project-key "<project>" \
  --environment-key "<env>" \
  --schedule-type ON_DEPLOY \
  [--deploy-project <key>] [--deploy-on-any-project] \
  [--include-tags @regression]
```

Follow another test run:
```bash
testery create-schedule ... --schedule-type FOLLOW_TEST_RUN --follow-test-run <id>
```

## Other useful flags

- `--build-id <id>` / `--git-ref <sha>`: pin to a specific build / commit (omit for "latest").
- `--priority <n>` / `--run-specific-version`.
- `--copies`, `--parallelize-by-file`, `--parallelize-by-test`.
- `--variable KEY=VALUE` (repeatable).
- `--test-suite "Name"`.
- `--timeout-minutes`, `--test-timeout-seconds`, `--test-filter-regex`.
