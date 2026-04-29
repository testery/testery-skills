---
name: testery-report-test-run
description: Output per-test results for a completed Testery run as a pretty pass/fail summary with emojis. Use when the user asks for results, a status report, or wants to see which tests passed/failed.
---

# Report a Testery test run

Wraps `testery report-test-run`. Fetches per-test results in JSON, then renders a human-friendly summary with status emojis.

## Status legend

- ✅ passed
- ❌ failed
- ⏭️ skipped / pending
- 🟡 running / in-progress
- ⚠️ errored / unknown

## Steps

1. Fetch results as JSON (so we can format ourselves):
   ```bash
   testery report-test-run \
     --token "$TESTERY_TOKEN" \
     --test-run-id <id> \
     --output json \
     --outfile /tmp/testery-run-<id>.json
   ```

2. Read `/tmp/testery-run-<id>.json` and produce output in this shape:

   ```
   Testery Test Run <id>  ·  <project> @ <env>
   ─────────────────────────────────────────────
   ✅ login.feature › User logs in successfully           1.2s
   ✅ login.feature › User sees error on bad password     0.8s
   ❌ checkout.feature › User completes checkout          3.4s
       → AssertionError: expected "Order placed" got "Error"
   ⏭️ profile.feature › Avatar upload (skipped: @wip)
   ─────────────────────────────────────────────
   Total: 4   ✅ 2   ❌ 1   ⏭️ 1     Duration: 5.4s
   Status: ❌ FAILED
   ```

   Mapping rules (Testery result statuses → emoji):
   - `PASS` / `PASSED` → ✅
   - `FAIL` / `FAILED` → ❌
   - `SKIP` / `SKIPPED` / `PENDING` / `IGNORED` → ⏭️
   - `RUNNING` / `IN_PROGRESS` / `QUEUED` → 🟡
   - anything else → ⚠️ (include the raw status)

3. For failed tests, include the error message / stack snippet beneath the line (indented with `    →`). Truncate long stacks to ~5 lines.

4. End with a one-line totals row and an overall verdict (`✅ PASSED` if zero failures, otherwise `❌ FAILED`).

5. If `--outfile` is undesirable, write the JSON to a temp path and clean it up after rendering.

## CI use

If the user wants a non-interactive report (e.g., for CI logs), pass `--fail-on-failure` so the CLI itself exits non-zero on failures:

```bash
testery report-test-run --token "$TESTERY_TOKEN" --test-run-id <id> --output json --fail-on-failure
```

The emoji rendering is still applied on top; the exit code is propagated for CI.
