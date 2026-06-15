use v6.d;

unit class BDD::Behave::Playwright;

method dist-version(--> Version) {
  Version.new($?DISTRIBUTION.meta<version> // '*');
}

method dist-meta() {
  $?DISTRIBUTION.meta;
}
