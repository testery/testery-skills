---
name: cucumber-run-local
description: Run CucumberJS + Playwright tests locally on the current developer machine. Use when the user asks to "run the tests", "run cucumber", or "run locally".
---

# Run Cucumber tests locally

## Whole suite

```bash
npm test
```

(equivalent to `cucumber-js`, configured by `cucumber.js`)

## A single feature

```bash
npx cucumber-js features/<file>.feature
```

## A subset by tag

```bash
npx cucumber-js --tags "@smoke and not @ignore"
```

## Dry run (no execution; reports undefined steps)

```bash
npx cucumber-js --dry-run
```

## Steps

1. Confirm the project has `cucumber.js` and `package.json` with a `test` script (this is the example-cucumberjs-playwright shape).
2. Pick whole-suite, single-feature, or tag-filtered.
3. Run the command.
4. Reports land at `cucumber-report.json` and `cucumber-report.html` (per `cucumber.js`).
