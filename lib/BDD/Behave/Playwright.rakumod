use v6.d;

use BDD::Behave::Playwright::Lifecycle ();
use BDD::Behave::Playwright::Matchers ();
use BDD::Behave::Playwright::Session;

class BDD::Behave::Playwright {
  method dist-version(--> Version) {
    Version.new($?DISTRIBUTION.meta<version> // '*');
  }

  method dist-meta() {
    $?DISTRIBUTION.meta;
  }

  method install($config, Str :$type = 'system', :$artifacts, Bool :$trace --> Nil) {
    BDD::Behave::Playwright::Session::configure(:$artifacts, :$trace);

    $config.before-all({ BDD::Behave::Playwright::Session::start-browser }, :$type);
    $config.before-each({ BDD::Behave::Playwright::Session::open-page }, :$type);
    $config.after-each({ BDD::Behave::Playwright::Session::finish-page }, :$type);
    $config.after-all({ BDD::Behave::Playwright::Session::stop-browser }, :$type);

    $config.include(BDD::Behave::Playwright::Session::PageHelper, :$type);
  }
}

sub playwright-page(|args) is export {
  BDD::Behave::Playwright::Lifecycle::playwright-page(|args);
}

sub fixture-url(|args) is export {
  BDD::Behave::Playwright::Lifecycle::fixture-url(|args);
}

sub page() is export {
  BDD::Behave::Playwright::Session::current-page();
}
