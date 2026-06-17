use v6.d;

use BDD::Behave::Failures;

unit module BDD::Behave::Playwright::Diagnostics;

my $sequence = 0;

sub next-stem(Str $dir --> Str) {
  $*SPEC.catfile($dir, "failure-{$*PID}-{++$sequence}");
}

our sub artifacts-dir($explicit?) is export {
  ($explicit // %*ENV<PLAYWRIGHT_ARTIFACTS> // 'playwright-artifacts').Str;
}

our sub tracing-enabled($explicit?) is export {
  ($explicit // ?%*ENV<PLAYWRIGHT_TRACE>).Bool;
}

our sub failure-count(--> Int) is export {
  Failures.list.elems;
}

our sub write-failure-artifacts($page, $context, Str :$dir!, Bool :$trace --> Str) is export {
  my $stem;

  try {
    mkdir $dir unless $dir.IO.d;
    $stem = next-stem($dir);

    $page.screenshot(path => "$stem.png");
    $context.stop-tracing(path => "$stem.zip") if $trace;
  }

  $stem;
}

our sub on-example-end($page, $context, Int $failure-base, Str :$dir!, Bool :$trace --> Bool) is export {
  my $failed = Failures.list.elems > $failure-base;

  if $failed {
    write-failure-artifacts($page, $context, :$dir, :$trace);
  }
  else {
    try { $context.stop-tracing if $trace }
  }

  $failed;
}
