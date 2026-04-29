# testery-skills

A library of [Claude Code](https://claude.ai/code) **skills** and **slash commands** for the [Testery](https://testery.io) test orchestration platform, plus skills tailored to **CucumberJS + Playwright** projects.

Clone, run `install.sh` (or `install.ps1` on Windows), and Claude will know how to drive the entire Testery CLI surface (creating test runs, uploading artifacts, registering environments, scheduling runs, and more) alongside skills for adding scenarios and steps to a Cucumber suite and executing them locally or on Testery (using either your local working copy or the Git-hosted version).

## What you get

### Slash commands (`/testery-*`)

| Command | What it does |
|---|---|
| `/testery-onboard` | **Start here.** Sign up / log in, capture API key, persist it |
| `/testery-init` | Scaffold Cucumber+Playwright in this project and wire it to Testery |
| `/testery-create-test-run` | Submit a Git-based test run |
| `/testery-monitor-test-run` | Follow a run to completion |
| `/testery-cancel-test-run` | Cancel a running test run |
| `/testery-upload-artifacts` | Upload a local file/dir as a build |
| `/testery-register-environment` | Create a new environment |
| `/testery-update-environment` | Update an existing environment |
| `/testery-deregister-environment` | Delete an environment |
| `/testery-list-environments` | List environments |
| `/testery-upload-environment-file` | Upload a file to an env |
| `/testery-create-schedule` | Cron / on-deploy / follow schedules |
| `/testery-delete-schedule` | Remove a schedule |
| `/testery-create-deploy` | Notify Testery of a deploy |
| `/testery-create-alert` | Set up an alert (UI/API guidance) |
| `/testery-add-file` | Attach a file to a test run |
| `/testery-report-test-run` | Output per-test results |
| `/testery-list-active-test-runs` | Show in-flight runs |
| `/testery-run-test-plan` | Execute a saved test plan |
| `/testery-load-users` | Bulk-load users |
| `/testery-verify-token` | Auth health check |
| `/testery-run-cucumber-local` | Run Cucumber tests on this machine |
| `/testery-run-cucumber-on-testery` | Run Cucumber tests on Testery (local build OR remote Git) |
| `/testery-add-cucumber-scenario` | Add a feature/scenario + step defs |

### Skills (loaded automatically by Claude when relevant)

All `testery-*` skills wrap the [Testery CLI](https://github.com/testery/testery-cli). Read-only inspection (listing projects/runs/results) can also be served by the [Testery MCP server](https://github.com/testery/testery-mcp) if you have it configured. Cucumber-shaped skills (`cucumber-*`) are modeled on `example-cucumberjs-playwright`.

## Install

### macOS / Linux / Git Bash on Windows

```bash
./install.sh             # user-level: ~/.claude/
./install.sh --project   # project-level: ./.claude/ in cwd
./install.sh --dry-run   # show what would be installed
./install.sh --force     # overwrite existing entries
```

### Native PowerShell

```powershell
./install.ps1            # user-level: $HOME\.claude\
./install.ps1 -Project   # project-level: .\.claude\
./install.ps1 -DryRun
./install.ps1 -Force
```

### Uninstall

```bash
./uninstall.sh [--project] [--dry-run]
./uninstall.ps1 [-Project] [-DryRun]
```

## Quickstart

The fastest path:

```
/testery-onboard      # signup or login on testery.io, persist your API key
/testery-init         # scaffold Cucumber+Playwright + register the project on Testery
```

`/testery-onboard` opens `https://app.testery.io/signup` (or `/login` if you already have an account), walks you through generating an API key, then writes it to `~/.testery/credentials` (chmod 600) and your shell rc so it sticks across sessions. `/testery-init` scaffolds the project, runs a local smoke, registers it on Testery, and (optionally) fires the first cloud run.

## Prerequisites

1. **Testery CLI** on PATH (auto-installed by `/testery-onboard` if missing):
   ```bash
   pip install testery
   ```
2. **API token**: easiest via `/testery-onboard`. Manual:
   ```bash
   export TESTERY_TOKEN=<your-token>           # bash/zsh
   $env:TESTERY_TOKEN = '<your-token>'         # PowerShell
   ```
3. **Optional**: configure the Testery MCP server in Claude Desktop / Claude Code for richer read-only inspection. See `../testery-mcp/CLAUDE.md`.
4. **Cucumber skills** assume a project shaped like `example-cucumberjs-playwright/` (`features/`, `stepDefinitions/`, `pageObjects/`, `cucumber.js`, `package.json` with a `test` script).

## How it's wired

- Slash commands live in `commands/` → install to `<base>/.claude/commands/<name>.md`.
- Skills live in `skills/<name>/SKILL.md` → install to `<base>/.claude/skills/<name>/SKILL.md`.
- Each slash command delegates to its corresponding skill, so the documented behavior is in one place.
- For write operations (create test run, upload artifacts, schedules, environments, deploys, monitoring), skills shell out to the CLI. For read/exploration that overlaps with the MCP server, skills note when MCP tools may be more convenient.

## Layout

```
testery-skills/
├── README.md
├── install.sh / install.ps1
├── uninstall.sh / uninstall.ps1
├── skills/
│   ├── testery-cli-setup/
│   ├── testery-create-test-run/
│   ├── testery-monitor-test-run/
│   ├── ...
│   ├── cucumber-add-scenario/
│   ├── cucumber-add-step-definition/
│   ├── cucumber-add-page-object/
│   ├── cucumber-run-local/
│   ├── cucumber-run-on-testery-local-build/
│   └── cucumber-run-on-testery-remote/
└── commands/
    └── testery-*.md
```
