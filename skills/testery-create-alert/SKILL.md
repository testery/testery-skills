---
name: testery-create-alert
description: Create a Testery alert (notification on test run failure / threshold). Use when the user asks to "be notified when X fails" or "set up an alert".
---

# Create a Testery alert

The Testery CLI does not currently expose a top-level `create-alert` command. Two paths:

1. **Web UI**: alerts are configured per project under **Project Settings → Alerts** in the Testery web app. Direct the user there.
2. **REST API**: POST to the alerts endpoint on `https://api.testery.io` (see Testery API docs). Construct the call with `curl` using `Authorization: Bearer $TESTERY_TOKEN`.

If the user has a specific alert config in mind, ask them whether to:
- Open the web UI, or
- Make a direct API call (collect channel: email/Slack/webhook, trigger condition, project, environment).

This skill is a placeholder until the CLI/MCP gain a first-class alerts command.
