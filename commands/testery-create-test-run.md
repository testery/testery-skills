---
description: Submit a Git-based test run to Testery (project + environment + git-ref/branch/build).
---

Use the `testery-create-test-run` skill to submit a test run to Testery via the `testery create-test-run` CLI command.

User input (may be empty: ask follow-up questions if so): $ARGUMENTS

Required: `--project-key`, `--environment-key`, and one of `--git-ref`, `--git-branch`, `--build-id`, or `--latest-deploy`.
After submission, report the `test_run_id` and offer to monitor it via `/testery-monitor-test-run`.
