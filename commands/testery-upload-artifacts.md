---
description: Upload a local file or directory of build artifacts to Testery, tied to a build-id.
---

Use the `testery-upload-artifacts` skill (`testery upload-build-artifacts`).

User input: $ARGUMENTS

Required: `--project-key`, `--build-id`, `--path`. Directories are auto-zipped (excluding `.git`, `node_modules`).
