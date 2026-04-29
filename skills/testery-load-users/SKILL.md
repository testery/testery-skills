---
name: testery-load-users
description: Bulk-load users into a Testery account from a JSON/CSV file. Use for organization onboarding.
---

# Load Testery users

Wraps `testery load-users`.

```bash
testery load-users \
  --token "$TESTERY_TOKEN" \
  --user-file ./users.json
```

Confirm the file format with the user before running: this is a write operation that affects org membership.
