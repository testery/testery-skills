---
name: cucumber-add-step-definition
description: Add a Given/When/Then step definition to a CucumberJS + Playwright project. Use when scenarios reference an undefined step.
---

# Add a step definition

## Steps

1. Locate the right `stepDefinitions/<Area>Steps.ts` file (one per page/area, e.g. `LoginSteps.ts`, `NavigationSteps.ts`). Create a new `*Steps.ts` only if no existing file fits.
2. Get cucumber-js to print the snippet to start from:
   ```bash
   npx cucumber-js --dry-run features/<file>.feature
   ```
3. Implement the step. Conventions in this project:
   - Imports: `import { Given, When, Then } from '@cucumber/cucumber'`
   - World: `async function (this: OurWorld, ...args)` (the project provides `OurWorld` via `@clubspark-qa/autotests-core/dist/types/world` or similar: match the existing imports in sibling files).
   - Use page objects from `pageObjects/` rather than driving Playwright directly when one exists.
   - Quoted args use cucumber expressions: `{string}`, `{int}`, etc.
4. Re-run `--dry-run`; the step should now resolve.

## Skeleton

```ts
import { When } from '@cucumber/cucumber'
import { OurWorld } from '@clubspark-qa/autotests-core/dist/types/world'

When(`I navigate to {string}`, async function (this: OurWorld, url: string) {
  await this.page.goto(url, { timeout: 30000 })
})
```
