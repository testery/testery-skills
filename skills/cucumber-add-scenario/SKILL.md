---
name: cucumber-add-scenario
description: Add a new Scenario (or Feature) to a CucumberJS + Playwright project. Use when the user asks to "add a test", "add a scenario", or "add a feature" in a project shaped like example-cucumberjs-playwright.
---

# Add a Cucumber scenario

Project shape (mirrors `example-cucumberjs-playwright/`):

- Features: `features/*.feature`
- Step defs: `stepDefinitions/*Steps.ts` (one per page/area)
- Page objects: `pageObjects/`
- Config: `cucumber.js`, `testConfig.json`

## Steps

1. Determine whether the scenario fits an existing `.feature` (same Feature heading) or needs a new file.
2. **Existing feature**: append a `Scenario:` block. Match the project's tag conventions (e.g. `@pass`, `@fail`, `@smoke`). Keep `Given/When/Then` phrasing close to existing steps in the file so step definitions can be reused.
3. **New feature**: create `features/<name>.feature` with a `Feature:` heading and one or more `Scenario:` blocks.
4. Run `npx cucumber-js --dry-run features/<name>.feature` to detect any undefined steps. For each undefined step, follow up with the `cucumber-add-step-definition` skill.
5. Verify locally with the `cucumber-run-local` skill.

## Example block

```gherkin
@smoke
Scenario: User searches Yahoo
  When I navigate to "http://www.yahoo.com"
  Then the page title is 'Yahoo'
```
