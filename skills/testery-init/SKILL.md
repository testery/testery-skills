---
name: testery-init
description: Bootstrap a project with CucumberJS + Playwright tests AND wire it up to Testery in one shot. Scaffolds files, installs deps, registers a Testery project + environment, runs a local smoke test, then optionally fires the first run on Testery. Use when the user says "set up Testery here", "add Cucumber/Playwright to this project", "init Testery", or starts in an empty repo.
---

# Initialize Testery + Cucumber/Playwright in a project

End state: working CucumberJS + Playwright suite locally, a Testery project + environment registered, and the first green run on Testery (optional).

## Pre-flight

1. **Auth.** If `TESTERY_TOKEN` isn't valid, hand off to the `testery-onboard` skill first.
2. **Git status.** Note whether the cwd is a git repo. If not, ask whether to `git init`. (Optional: Testery doesn't require it for `--build-id` flows, but `--git-branch` flows do.)
3. **Existing setup detection.** Look for existing `cucumber.js`, `features/`, `package.json` with `@cucumber/cucumber` + `playwright` deps. If present, skip scaffolding and jump to the Testery registration step.

## Scaffold (skip files that already exist)

Mirror the `example-cucumberjs-playwright` layout. Create:

### `package.json`
```json
{
  "name": "<project-folder-name>",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "test": "cucumber-js",
    "test:dry": "cucumber-js --dry-run"
  },
  "devDependencies": {
    "@cucumber/cucumber": "^10.0.0",
    "@playwright/test": "^1.40.0",
    "@types/node": "^20.0.0",
    "playwright": "^1.40.0",
    "ts-node": "^10.9.0",
    "typescript": "^5.0.0"
  }
}
```

### `cucumber.js`
```js
module.exports = {
  default: {
    requireModule: ['ts-node/register'],
    require: ['./stepDefinitions/**/*.ts'],
    publishQuiet: true,
    formatOptions: { snippetInterface: 'async-await' },
    format: ['progress-bar', 'json:cucumber-report.json', 'html:cucumber-report.html'],
  },
}
```

### `tsconfig.json`
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true
  }
}
```

### `features/sample.feature`
```gherkin
Feature: Sample navigation

  @smoke
  Scenario: User loads the Testery site
    When I navigate to "https://www.testery.io"
    Then the page title contains "Testery"
```

### `stepDefinitions/NavigationSteps.ts`
```ts
import { When, Then, Before, After, setDefaultTimeout } from '@cucumber/cucumber'
import { chromium, Browser, Page } from 'playwright'
import { strict as assert } from 'assert'

setDefaultTimeout(60_000)

let browser: Browser
let page: Page

Before(async function () {
  browser = await chromium.launch({ headless: true })
  page = await browser.newPage()
})

After(async function () {
  await browser?.close()
})

When('I navigate to {string}', async function (url: string) {
  await page.goto(url, { timeout: 30_000 })
})

Then('the page title contains {string}', async function (expected: string) {
  const title = await page.title()
  assert.ok(title.includes(expected), `expected title to contain "${expected}", got "${title}"`)
})
```

### `pageObjects/.gitkeep` (empty placeholder dir)

### `.gitignore` (append, don't overwrite)
```
node_modules/
cucumber-report.json
cucumber-report.html
.testery/
```

### `testery.yml` (project-level Testery config Testery will pick up)
```yaml
framework: cucumber-playwright
testCommand: npm test
```

## Install + smoke

```bash
npm install
npx playwright install chromium
npm test
```

Render the local result with the same emoji format used by `testery-report-test-run` (✅ ❌ ⏭️). If the smoke fails, stop and help the user before doing any Testery wiring.

## Register on Testery

Ask the user for:
- **Project key** (default: kebab-cased folder name)
- **Project name** (default: titlecased folder name)
- **First environment key + name** (default: `dev` / `Dev`)
- (Optional) URL of the app under test → set as a `BASE_URL` variable

Then:

1. **Project**: Testery has no `create-project` CLI command, so use the REST API directly:
   ```bash
   curl -fsS -X POST "https://api.testery.io/projects" \
     -H "Authorization: Bearer $TESTERY_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"key":"<project-key>","name":"<project-name>","framework":"CUCUMBER_PLAYWRIGHT"}'
   ```
   Capture the response (id) for confirmation. If the project already exists, that's fine: continue.

2. **Environment**: use the CLI:
   ```bash
   testery create-environment \
     --token "$TESTERY_TOKEN" \
     --key "<env-key>" \
     --name "<env-name>" \
     [--variable "BASE_URL=<url>"]
   ```

## First run on Testery (optional, ask)

Two options: ask the user which:

- **Local working copy** (no git push needed):
  ```bash
  BUILD_ID="init-$(date +%s)"
  testery upload-build-artifacts --token "$TESTERY_TOKEN" --project-key "<project-key>" --build-id "$BUILD_ID" --path .
  testery create-test-run     --token "$TESTERY_TOKEN" --project-key "<project-key>" --environment-key "<env-key>" --build-id "$BUILD_ID" --wait-for-results --output json
  ```
- **From Git** (requires the repo to be pushed and connected to Testery):
  ```bash
  testery create-test-run --token "$TESTERY_TOKEN" --project-key "<project-key>" --environment-key "<env-key>" --git-branch "$(git rev-parse --abbrev-ref HEAD)" --wait-for-results --output json
  ```

Pipe results through the emoji renderer from `testery-report-test-run`.

## Wrap-up

Print a short "what's next" list:
- `/testery-add-cucumber-scenario` to add more tests
- `/testery-create-schedule` to run on a cron / on deploy
- `/testery-monitor-test-run <id>` to watch a run
- The Testery web app for dashboards & alerts

## Idempotency

The skill should be safe to re-run: every step checks for prior existence (files, project, environment) and skips/upserts rather than failing.
