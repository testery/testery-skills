---
name: testery-add-file
description: Attach a file (artifact, log, or input) to an existing Testery test run. Use to add context to a run after it has been created.
---

# Add a file to a test run

Wraps `testery add-file`.

```bash
testery add-file \
  --token "$TESTERY_TOKEN" \
  --test-run-id <id> \
  --file-path ./path/to/file \
  --kind <input|artifact|log>
```
