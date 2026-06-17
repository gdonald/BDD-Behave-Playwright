# BDD::Behave::Playwright

Browser lifecycle hooks and Playwright-aware matchers for
[BDD::Behave](https://github.com/gdonald/BDD-Behave) examples.

It is glue between BDD::Behave and
[WWW::Playwright](https://github.com/gdonald/WWW-Playwright). It contains no
browser driving of its own; that all lives in WWW::Playwright. This distribution
wires a Playwright page into a behave `describe`/`it` flow and lets you write
expectations against it.

## Install

```
zef install BDD::Behave::Playwright
```

The browser runtime comes from WWW::Playwright, which needs Node and a Chromium
binary. After installing, run its installer once:

```
install
```

This runs `npm install` for the sidecar and `npx playwright install chromium`.

## Example

```raku
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'signing up', {
  playwright-page(fixture => 'specs/fixtures/form.html');

  it 'greets the user after the form is submitted', -> $_ {
    .page.locator('#username').fill('Ada');
    .page.locator('#submit').click;

    expect(.page.locator('#welcome')).to.have-text('Welcome, Ada');
  }
}
```

## What the glue adds

- A `playwright-page` helper that launches one browser per `describe`, gives each
  example a fresh context and page, and exposes the page as a `let` named `page`.
- Matchers over `Locator` and `Page`: `be-visible`, `be-hidden`, `be-enabled`,
  `be-disabled`, `be-checked`, `have-text`, `have-value`, `have-attribute`,
  `have-count`, `have-css`, `have-title`, `have-current-path`. They negate with
  `.not` and poll Playwright's auto-waiting instead of re-implementing waits.
- Failure diagnostics: a screenshot (and optional trace) captured to an artifacts
  directory when an example fails.

## Documentation

Full docs are built from `docs-src` with mkdocs.

## License

Artistic-2.0
