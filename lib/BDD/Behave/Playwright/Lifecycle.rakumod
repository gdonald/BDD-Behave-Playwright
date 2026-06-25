use v6.d;

use BDD::Behave;
use WWW::Playwright;
use BDD::Behave::Playwright::Diagnostics;
use BDD::Behave::Playwright::Session;

unit module BDD::Behave::Playwright::Lifecycle;

our sub fixture-url(Str $path --> Str) is export {
  'file://' ~ $path.IO.absolute;
}

our sub playwright-page(Str :$fixture, :$artifacts, Bool :$trace --> Nil) is export {
  my $playwright;
  my $browser;
  my $context;
  my $page;
  my $failure-base;

  my $target    = $fixture.defined ?? fixture-url($fixture) !! Str;
  my $dir       = artifacts-dir($artifacts);
  my $trace-on  = tracing-enabled($trace);

  before-all {
    $playwright = WWW::Playwright.start;
    $browser    = $playwright.launch;
  }

  before-each {
    $context = $browser.new-context;
    $context.start-tracing if $trace-on;

    $page = $context.new-page;
    $page.goto($target) if $target.defined;

    set-current-page($page);

    $failure-base = failure-count();
  }

  &let('page', { $page });

  after-each {
    on-example-end($page, $context, $failure-base, :$dir, :trace($trace-on));

    $context.close if $context;
    $context = Nil;
    $page    = Nil;

    set-current-page(Nil);
  }

  after-all {
    $browser.close   if $browser;
    $playwright.stop if $playwright;
  }

  Nil;
}
