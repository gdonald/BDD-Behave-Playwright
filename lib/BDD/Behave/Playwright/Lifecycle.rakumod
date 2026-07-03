use v6.d;

use BDD::Behave;
use WWW::Playwright;
use BDD::Behave::Playwright::Diagnostics;
use BDD::Behave::Playwright::Session;

unit module BDD::Behave::Playwright::Lifecycle;

our sub fixture-url(Str $path --> Str) is export {
  'file://' ~ $path.IO.absolute;
}

our sub headless-from-env(%env = %*ENV --> Bool) is export {
  my $show = (%env<SHOW_CHROME> // '').trim.lc;

  so $show eq ('' | '0' | 'false' | 'no' | 'off')
}

our sub goto(Str:D $url --> Nil) is export {
  current-page().goto($url);
}

our sub visit(Str:D $path --> Nil) is export {
  my $url = $path ~~ / ^ \w+ '://' / ?? $path !! (current-base-url() // '') ~ $path;

  goto($url);
}

our sub playwright-page(Str :$fixture, :$base-url, :%context, :$artifacts, Bool :$trace --> Nil) is export {
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
    $browser    = $playwright.launch(:headless(headless-from-env()));
  }

  before-each {
    $context = $browser.new-context(|%context);
    $context.start-tracing if $trace-on;

    $page = $context.new-page;
    $page.goto($target) if $target.defined;

    set-current-page($page);
    set-current-base-url($base-url);

    $failure-base = failure-count();
  }

  &let('page', { $page });

  after-each {
    on-example-end($page, $context, $failure-base, :$dir, :trace($trace-on));

    $context.close if $context;
    $context = Nil;
    $page    = Nil;

    set-current-page(Nil);
    set-current-base-url(Nil);
  }

  after-all {
    $browser.close   if $browser;
    $playwright.stop if $playwright;
  }

  Nil;
}
