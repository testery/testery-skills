---
name: cucumber-add-page-object
description: Create a new Playwright page object class in a CucumberJS + Playwright project. Use when adding tests for a page that has no existing page object.
---

# Add a page object

## Steps

1. Inspect existing classes in `pageObjects/` to match style (constructor signature, locator strategy, exported singleton vs class).
2. Create `pageObjects/<Name>Page.ts`: one class per page, named `<Name>Page`, default-exported.
3. Expose intent-revealing methods (e.g. `loginAs(user)`, `submit()`) that wrap raw locator calls: step definitions should not contain raw selectors.
4. Reference the page object from steps via the project's `pageFactory` or equivalent helper (mirror sibling `*Steps.ts` files).

## Skeleton

```ts
import { Page } from 'playwright'

export default class LoginPage {
  constructor(private page: Page) {}

  async loginAs(user: { username: string; password: string }) {
    await this.page.fill('#username', user.username)
    await this.page.fill('#password', user.password)
    await this.page.click('button[type=submit]')
  }
}
```
