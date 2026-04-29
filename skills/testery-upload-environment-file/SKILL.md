---
name: testery-upload-environment-file
description: Upload a file (e.g., a config, fixture, or credential file) and attach it to a Testery environment. Use to make the file available to tests running in that env.
---

# Upload a file to a Testery environment

Wraps `testery upload-environment-file`.

```bash
testery upload-environment-file \
  --token "$TESTERY_TOKEN" \
  --environment-key "<env-key>" \
  --file-name "<remote-name>" \
  --source-path ./path/to/local/file
```
