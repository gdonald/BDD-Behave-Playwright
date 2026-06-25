# Changelog

All notable changes to `BDD::Behave::Playwright` are documented here. Versions
follow semver (MAJOR.MINOR.PATCH).

## v0.9.0 - 2026-06-25

### Added

- `playwright-page` lifecycle helper that launches one browser per `describe`,
  gives each example a fresh context and page, and exposes the page as a `let`
  named `page`. Accepts `fixture`, `artifacts`, and `trace` options.
- `BDD::Behave::Playwright.install($config, :type<system>)` for registering the
  browser lifecycle once in a `.behave` config file instead of calling
  `playwright-page` in each `describe`. It wires `before-all` / `before-each` /
  `after-each` / `after-all` hooks and a page helper to every group tagged with
  the given `type`, and accepts the same `artifacts` and `trace` options.
- A `page` term and `fixture-url` sub exported from `BDD::Behave::Playwright`,
  plus a `.page` accessor on the example topic, for reaching the current page in
  the config-registered system-test flow.
- `BDD::Behave::Playwright::Session` module backing the lifecycle (`configure`,
  `start-browser`, `open-page`, `current-page`, `set-current-page`,
  `finish-page`, `stop-browser`, and the `PageHelper` class).
- Matchers over `Locator` and `Page`: `be-visible`, `be-hidden`, `be-enabled`,
  `be-disabled`, `be-checked`, `have-text`, `have-value`, `have-attribute`,
  `have-count`, `have-css`, `have-title`, and `have-current-path`. Each negates
  with `.not` and reuses Playwright's auto-waiting rather than re-implementing
  waits. `have-css` mirrors Capybara's `have_css` (`count`, `minimum`,
  `maximum`, `text`). `have-current-path` matches the path by default and the
  full URL with `url => True`.
- Failure diagnostics in `BDD::Behave::Playwright::Diagnostics`: a screenshot
  captured to a configurable artifacts directory when an example fails, plus an
  optional Playwright trace gated by an env flag. A failing diagnostic does not
  fail the suite.
- mkdocs documentation under `docs-src` covering installation, lifecycle,
  matchers, diagnostics, system tests, and an end-to-end example.
