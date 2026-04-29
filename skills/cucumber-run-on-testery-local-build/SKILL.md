---
name: cucumber-run-on-testery-local-build
description: Run the LOCAL working-copy version of a CucumberJS + Playwright project on Testery (zip up the cwd, upload, then create a test run pinned to that build). Use when the user wants to test their uncommitted local changes on Testery infrastructure.
---

# Run local build on Testery

This wraps the CLI flow:
1. `testery upload-build-artifacts`: zips the project dir (excluding `.git` and `node_modules`) and uploads.
2. `testery create-test-run --build-id ...`: runs against that uploaded bundle.

## Template

```bash
BUILD_ID="local-$(date +%s)"

testery upload-build-artifacts \
  --token "$TESTERY_TOKEN" \
  --project-key "<project>" \
  --build-id "$BUILD_ID" \
  --path .

testery create-test-run \
  --token "$TESTERY_TOKEN" \
  --project-key "<project>" \
  --environment-key "<env>" \
  --build-id "$BUILD_ID" \
  [--include-tags @smoke] [--runner-count 4] \
  [--wait-for-results --fail-on-failure]
```

## Steps

1. Confirm the project key and environment key with the user (or list them via `testery list-environments`).
2. Pick a build ID (timestamp or git short SHA).
3. Run upload, then create-test-run with `--build-id`.
4. Optionally chain `cucumber-run-on-testery-remote` is **not** what you want here: that runs the committed/remote version. Use this skill for local code.
