---
name: testery-upload-artifacts
description: Upload a local file or directory of build artifacts to Testery, associated with a build ID. Use this to ship a local test bundle (e.g., a Cucumber+Playwright project) up to Testery so it can be executed remotely.
---

# Upload build artifacts

Wraps `testery upload-build-artifacts`. Uploads a file or a directory (zipped automatically) and ties it to a `build-id` that you can later reference from `create-test-run --build-id`.

## Template

Single file:
```bash
testery upload-build-artifacts \
  --token "$TESTERY_TOKEN" \
  --project-key "<project>" \
  --build-id "<unique-id>" \
  --path ./dist/tests.zip \
  [--branch "<branch>"]
```

Directory (auto-zipped, excludes `.git` and `node_modules`):
```bash
testery upload-build-artifacts \
  --token "$TESTERY_TOKEN" \
  --project-key "<project>" \
  --build-id "<unique-id>" \
  --path . \
  [--branch "<branch>"]
```

## Steps

1. Pick a `build-id` (timestamp, git short SHA, or CI build number: must be unique within the project).
2. Run the command. The CLI zips directories before upload.
3. Hand the same `build-id` to `testery create-test-run --build-id <id>` to execute the uploaded code.

## Common pairing

- `testery-cli-setup` → `testery-upload-artifacts` → `testery-create-test-run` (with `--build-id`) → `testery-monitor-test-run`.
