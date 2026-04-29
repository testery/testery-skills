---
description: Sign up, log in, or verify a Testery account, and persist the API token across sessions.
---

Use the `testery-onboard` skill.

If the user has a token in `$TESTERY_TOKEN` or `~/.testery/credentials` and `testery verify-token` succeeds, just confirm and stop.

Otherwise: ask whether they're new (signup) or returning (login), open the appropriate URL on testery.io, walk them through generating an API key, save it to `~/.testery/credentials` (chmod 600) and append the export to their shell rc / PowerShell profile so it persists.

User input (e.g., "new" or "existing"): $ARGUMENTS
