use v6.d;

use WWW::Playwright;
use BDD::Behave::Playwright::Diagnostics;

unit module BDD::Behave::Playwright::Session;

my $playwright;
my $browser;
my $context;
my $page;
my $failure-base;
my $dir;
my $trace-on;

our sub configure(:$artifacts, Bool :$trace --> Nil) is export {
  $dir      = artifacts-dir($artifacts);
  $trace-on = tracing-enabled($trace);
}

our sub start-browser(--> Nil) is export {
  $playwright = WWW::Playwright.start;
  $browser    = $playwright.launch;
}

our sub open-page(--> Nil) is export {
  $context = $browser.new-context;
  $context.start-tracing if $trace-on;

  $page = $context.new-page;

  $failure-base = failure-count();
}

our sub current-page() is export { $page }

our sub set-current-page($new-page --> Nil) is export {
  $page = $new-page;
}

our sub finish-page(--> Nil) is export {
  on-example-end($page, $context, $failure-base, :$dir, :trace($trace-on));

  $context.close if $context;
  $context = Nil;
  $page    = Nil;
}

our sub stop-browser(--> Nil) is export {
  $browser.close   if $browser;
  $playwright.stop if $playwright;
  $browser    = Nil;
  $playwright = Nil;
}

our class PageHelper {
  method page() { current-page() }
}
