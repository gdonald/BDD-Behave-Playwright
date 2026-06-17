use v6.d;

use BDD::Behave;
use WWW::Playwright;

unit module BDD::Behave::Playwright::Lifecycle;

our sub fixture-url(Str $path --> Str) is export {
  'file://' ~ $path.IO.absolute;
}

our sub playwright-page(Str :$fixture --> Nil) is export {
  my $playwright;
  my $browser;
  my $context;

  my $target = $fixture.defined ?? fixture-url($fixture) !! Str;

  before-all {
    $playwright = WWW::Playwright.start;
    $browser    = $playwright.launch;
  }

  before-each {
    $context = $browser.new-context;
  }

  &let('page', {
    my $page = $context.new-page;
    $page.goto($target) if $target.defined;
    $page;
  });

  after-each {
    $context.close if $context;
    $context = Nil;
  }

  after-all {
    $browser.close   if $browser;
    $playwright.stop if $playwright;
  }

  Nil;
}
