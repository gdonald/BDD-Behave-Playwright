use v6.d;

use BDD::Behave::Playwright::Lifecycle ();
use BDD::Behave::Playwright::Matchers ();

class BDD::Behave::Playwright {
  method dist-version(--> Version) {
    Version.new($?DISTRIBUTION.meta<version> // '*');
  }

  method dist-meta() {
    $?DISTRIBUTION.meta;
  }
}

sub playwright-page(|args) is export {
  BDD::Behave::Playwright::Lifecycle::playwright-page(|args);
}

sub fixture-url(|args) is export {
  BDD::Behave::Playwright::Lifecycle::fixture-url(|args);
}
