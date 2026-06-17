use v6.d;

use BDD::Behave;

unit module BDD::Behave::Playwright::Matchers;

constant DEFAULT-TIMEOUT = 4.0;
constant POLL-INTERVAL   = 0.05;

sub poll-until(&condition, Real $timeout --> Bool) {
  my $deadline = now + $timeout;

  loop {
    my $ok = False;
    try { $ok = ?condition() }

    return True  if $ok;
    return False if now >= $deadline;

    sleep POLL-INTERVAL;
  }
}

sub value-matches($actual, $expected --> Bool) {
  return ($actual ~~ $expected).Bool if $expected ~~ Regex;
  ($actual // '') eq $expected;
}

sub text-of($locator) { $locator.text-content // '' }

sub count-ok(Int $found, Mu $count, Mu $minimum, Mu $maximum --> Bool) {
  return $found == $count if $count.defined;

  my $min = $minimum // 1;
  my $max = $maximum // Inf;

  $min <= $found <= $max;
}

sub css-with-text(Str $selector, Mu $text --> Str) {
  return $selector without $text;

  my $escaped = $text.Str.subst('\\', '\\\\', :g).subst('"', '\\"', :g);
  $selector ~ ':has-text("' ~ $escaped ~ '")';
}

sub css-goal(Mu $count, Mu $minimum, Mu $maximum --> Str) {
  return "exactly $count"                  if $count.defined;
  return "between {$minimum // 1} and $maximum" if $maximum.defined;
  return "at least $minimum"               if $minimum.defined;
  "at least one";
}

define-matcher 'be-visible',
  match                   => -> $loc, :$timeout = DEFAULT-TIMEOUT { poll-until({ $loc.is-visible }, $timeout) },
  failure-message         => -> $loc, *% { "expected locator {$loc.handle} to be visible" },
  failure-message-negated => -> $loc, *% { "expected locator {$loc.handle} not to be visible" },
  description             => -> *% { 'be visible' };

define-matcher 'be-hidden',
  match                   => -> $loc, :$timeout = DEFAULT-TIMEOUT { poll-until({ !$loc.is-visible }, $timeout) },
  failure-message         => -> $loc, *% { "expected locator {$loc.handle} to be hidden" },
  failure-message-negated => -> $loc, *% { "expected locator {$loc.handle} not to be hidden" },
  description             => -> *% { 'be hidden' };

define-matcher 'be-enabled',
  match                   => -> $loc, :$timeout = DEFAULT-TIMEOUT { poll-until({ $loc.is-enabled }, $timeout) },
  failure-message         => -> $loc, *% { "expected locator {$loc.handle} to be enabled" },
  failure-message-negated => -> $loc, *% { "expected locator {$loc.handle} not to be enabled" },
  description             => -> *% { 'be enabled' };

define-matcher 'be-disabled',
  match                   => -> $loc, :$timeout = DEFAULT-TIMEOUT { poll-until({ !$loc.is-enabled }, $timeout) },
  failure-message         => -> $loc, *% { "expected locator {$loc.handle} to be disabled" },
  failure-message-negated => -> $loc, *% { "expected locator {$loc.handle} not to be disabled" },
  description             => -> *% { 'be disabled' };

define-matcher 'be-checked',
  match                   => -> $loc, :$timeout = DEFAULT-TIMEOUT { poll-until({ $loc.is-checked }, $timeout) },
  failure-message         => -> $loc, *% { "expected locator {$loc.handle} to be checked" },
  failure-message-negated => -> $loc, *% { "expected locator {$loc.handle} not to be checked" },
  description             => -> *% { 'be checked' };

define-matcher 'have-text',
  match => -> $loc, $expected, :$timeout = DEFAULT-TIMEOUT {
    poll-until({
      my $text = text-of($loc);
      $expected ~~ Regex ?? ($text ~~ $expected).Bool !! $text.contains($expected);
    }, $timeout);
  },
  failure-message         => -> $loc, $expected, *% { "expected locator {$loc.handle} to have text {$expected.gist}, but text was {text-of($loc).raku}" },
  failure-message-negated => -> $loc, $expected, *% { "expected locator {$loc.handle} not to have text {$expected.gist}, but text was {text-of($loc).raku}" },
  description             => -> $expected, *% { "have text {$expected.gist}" };

define-matcher 'have-value',
  match => -> $loc, $expected, :$timeout = DEFAULT-TIMEOUT {
    poll-until({ value-matches($loc.input-value, $expected) }, $timeout);
  },
  failure-message         => -> $loc, $expected, *% { "expected locator {$loc.handle} to have value {$expected.gist}, but value was {($loc.input-value // '').raku}" },
  failure-message-negated => -> $loc, $expected, *% { "expected locator {$loc.handle} not to have value {$expected.gist}, but value was {($loc.input-value // '').raku}" },
  description             => -> $expected, *% { "have value {$expected.gist}" };

define-matcher 'have-attribute',
  match => -> $loc, $name, $expected = Whatever, :$timeout = DEFAULT-TIMEOUT {
    poll-until({
      my $value = $loc.get-attribute($name);
      $expected ~~ Whatever ?? $value.defined !! ($value.defined && value-matches($value, $expected));
    }, $timeout);
  },
  failure-message => -> $loc, $name, $expected = Whatever, *% {
    my $goal = $expected ~~ Whatever ?? "attribute {$name.raku}" !! "attribute {$name.raku} {$expected.gist}";
    "expected locator {$loc.handle} to have $goal, but it was {$loc.get-attribute($name).raku}";
  },
  failure-message-negated => -> $loc, $name, $expected = Whatever, *% {
    my $goal = $expected ~~ Whatever ?? "attribute {$name.raku}" !! "attribute {$name.raku} {$expected.gist}";
    "expected locator {$loc.handle} not to have $goal, but it was {$loc.get-attribute($name).raku}";
  },
  description => -> $name, $expected = Whatever, *% {
    $expected ~~ Whatever ?? "have attribute {$name.raku}" !! "have attribute {$name.raku} {$expected.gist}";
  };

define-matcher 'have-count',
  match                   => -> $loc, Int $expected, :$timeout = DEFAULT-TIMEOUT { poll-until({ $loc.count == $expected }, $timeout) },
  failure-message         => -> $loc, $expected, *% { "expected locator {$loc.handle} to have count $expected, but found {$loc.count}" },
  failure-message-negated => -> $loc, $expected, *% { "expected locator {$loc.handle} not to have count $expected, but found {$loc.count}" },
  description             => -> $expected, *% { "have count $expected" };

define-matcher 'have-css',
  match => -> $root, Str $selector, :$count, :$minimum, :$maximum, :$text, :$timeout = DEFAULT-TIMEOUT {
    my $located = $root.locator(css-with-text($selector, $text));
    poll-until({ count-ok($located.count, $count, $minimum, $maximum) }, $timeout);
  },
  failure-message => -> $root, $selector, :$count, :$minimum, :$maximum, :$text, *% {
    my $found = $root.locator(css-with-text($selector, $text)).count;
    "expected the page to have CSS {$selector.raku} matching {css-goal($count, $minimum, $maximum)} node(s), but found $found";
  },
  failure-message-negated => -> $root, $selector, :$count, :$minimum, :$maximum, :$text, *% {
    my $found = $root.locator(css-with-text($selector, $text)).count;
    "expected the page not to have CSS {$selector.raku} matching {css-goal($count, $minimum, $maximum)} node(s), but found $found";
  },
  description => -> $selector, :$count, :$minimum, :$maximum, :$text, *% {
    "have CSS {$selector.raku} matching {css-goal($count, $minimum, $maximum)} node(s)";
  };
