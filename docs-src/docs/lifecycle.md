# Browser lifecycle

`playwright-page` wires the browser lifecycle into a `describe` block. It launches
one browser for the group, creates a fresh context and page for each example, and
closes them afterward so examples stay isolated.

## Setup

Call `playwright-page` at the top of a `describe`, passing the fixture to load:

```raku
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'the greeting page', {
  playwright-page(fixture => 'specs/fixtures/hello.html');

  it 'shows the greeting', {
    expect(page.locator('#greeting').text-content).to.eq('Hello, world');
  }
}
```

## The `page` term

`use BDD::Behave::Playwright` brings a `page` term into scope that returns the
current page:

```raku
it 'fills a field', {
  page.locator('#name').fill('Ada');
  expect(page.locator('#name').input-value).to.eq('Ada');
}
```

The same page is also reachable through the example's topic parameter as `.page`,
for blocks written `-> $_ { ... }`:

```raku
it 'fills a field', -> $_ {
  .page.locator('#name').fill('Ada');
}
```

Each example gets its own context and page, so state set in one example does not
leak into the next.

## Scope

- One browser is launched per `describe` group, in a `before-all` hook.
- Each example gets a fresh context and page, created in `before-each` and
  published as the `page` term.
- The context is closed in `after-each`; the browser is closed in `after-all`.

## Fixtures

`fixture-url` turns a filesystem path into an absolute `file://` URL:

```raku
fixture-url('specs/fixtures/hello.html');  # file:///abs/path/specs/fixtures/hello.html
```

`playwright-page(fixture => ...)` calls it for you. Pass an absolute or
working-directory-relative path to a local HTML file. Browser tests run against
local `file://` fixtures, never the network.
