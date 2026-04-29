---
name: testery-onboard
description: One-shot Testery auth onboarding: verifies an existing token, or walks a new user through signup/login at testery.io and persists their API key. Use at the start of any Testery work, or when the user says "set up Testery", "I don't have a Testery account yet", "log me in", or "where do I get a token?"
---

# Testery onboarding (signup / login / token persistence)

Goal: end this skill with a valid `TESTERY_TOKEN` available in the user's environment **and** persisted across sessions, regardless of whether they had a Testery account when they started.

## Decision tree

1. **CLI present?** Run `testery --help`. If missing:
   ```bash
   pip install testery
   ```
   (or `pipx install testery` if pip isn't available system-wide).

2. **Existing token?** Look in this order:
   - `$TESTERY_TOKEN` env var
   - `~/.testery/credentials` (single line: `TESTERY_TOKEN=<token>`)
   - User-supplied (ask)

   If found, verify:
   ```bash
   testery verify-token --token "$TESTERY_TOKEN"
   ```
   - Exit 0 → done. Confirm to user and stop.
   - Non-zero → token is bad/expired; fall through to step 3.

3. **No valid token: onboard the user.** Ask which path:

   - **Have an account → log in** → open `https://app.testery.io/login`
   - **New user → sign up** (free) → open `https://app.testery.io/signup`

   Open the URL using the platform-appropriate command:
   - Windows: `cmd //c start "<url>"` (from git bash) or `Start-Process "<url>"` (PowerShell)
   - macOS: `open "<url>"`
   - Linux: `xdg-open "<url>"`

   Then tell the user:
   > After signing in, go to **Account Settings → API Keys**, generate a key, and paste it back here.

4. **Capture the token.** Ask the user to paste it. Treat the value as secret: never echo it in tool output.

5. **Persist it.** Write to `~/.testery/credentials` and shell rc. (On Windows, also update the user's PowerShell profile.)

   ```bash
   mkdir -p ~/.testery
   umask 077
   printf 'TESTERY_TOKEN=%s\n' "<token>" > ~/.testery/credentials
   chmod 600 ~/.testery/credentials
   ```

   Append an export line **only if not already present** to whichever shell rc the user uses:

   ```bash
   # bash / git bash
   grep -q 'TESTERY_TOKEN' ~/.bashrc || \
     echo '[ -f ~/.testery/credentials ] && export $(grep -v "^#" ~/.testery/credentials | xargs)' >> ~/.bashrc

   # zsh
   grep -q 'TESTERY_TOKEN' ~/.zshrc || \
     echo '[ -f ~/.testery/credentials ] && export $(grep -v "^#" ~/.testery/credentials | xargs)' >> ~/.zshrc
   ```

   PowerShell profile (`$PROFILE`):
   ```powershell
   $line = '$env:TESTERY_TOKEN = (Get-Content "$HOME\.testery\credentials" | ForEach-Object { ($_ -split "=",2)[1] })'
   if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force | Out-Null }
   if (-not (Select-String -Path $PROFILE -Pattern 'TESTERY_TOKEN' -Quiet)) { Add-Content $PROFILE $line }
   ```

   Then export it for the **current** session so subsequent skills work immediately:
   ```bash
   export TESTERY_TOKEN="<token>"
   ```

6. **Re-verify.** Run `testery verify-token --token "$TESTERY_TOKEN"`. Confirm success to the user with a short summary (account email if the CLI returns it).

7. **Tell them what's next.** Suggest `/testery-init` (if they don't have a test project yet) or `/testery-list-environments` to see what's already configured.

## Security notes

- Never paste the token into chat output, log files, or commit it. The `~/.testery/credentials` file should be `chmod 600` and is per-user.
- If the user wants to rotate the token, they delete the credentials file (`rm ~/.testery/credentials`) and re-run this skill.
- For CI: skip this skill: set `TESTERY_TOKEN` as a secret in the CI environment instead.

## When this skill is NOT needed

- The user already has `TESTERY_TOKEN` exported and `verify-token` succeeds.
- A `~/.testery/credentials` file already exists and is valid.

In both cases, finish in step 2 with a one-line "✅ already authenticated as <email>".
