use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;
use BDD::Behave::Playwright::Diagnostics;
use WWW::Playwright;

sub png-count(Str $dir --> Int) {
  $dir.IO.d ?? $dir.IO.dir(test => /'.png' $/).elems !! 0;
}

describe 'failure diagnostics', {
  my $playwright;
  my $browser;
  my $context;
  my $page;
  my $dir = 'playwright-artifacts-spec';

  before-all {
    $playwright = WWW::Playwright.start;
    $browser    = $playwright.launch;
  }

  after-all {
    $browser.close   if $browser;
    $playwright.stop if $playwright;

    if $dir.IO.d {
      .unlink for $dir.IO.dir;
      $dir.IO.rmdir;
    }
  }

  before-each {
    $context = $browser.new-context;
    $page    = $context.new-page;
    $page.goto(fixture-url('specs/fixtures/hello.html'));
  }

  after-each {
    $context.close if $context;
  }

  it 'writes a non-empty screenshot to the artifacts dir', {
    my $stem = write-failure-artifacts($page, $context, :$dir);
    expect("$stem.png".IO.s).to.be-greater-than(0);
  }

  it 'writes a non-empty trace when tracing is enabled', {
    $context.start-tracing;
    my $stem = write-failure-artifacts($page, $context, :$dir, :trace);
    expect("$stem.zip".IO.s).to.be-greater-than(0);
  }

  it 'captures a screenshot when the example recorded a failure', {
    my $before = png-count($dir);
    on-example-end($page, $context, -1, :$dir);
    expect(png-count($dir)).to.be-greater-than($before);
  }

  it 'writes nothing when the example recorded no failure', {
    my $before = png-count($dir);
    on-example-end($page, $context, failure-count(), :$dir);
    expect(png-count($dir)).to.be($before);
  }

  it 'does not propagate an error when the page is unusable', {
    my $closed = $context.new-page;
    $closed.close;

    my $threw = False;
    try {
      write-failure-artifacts($closed, $context, :$dir);
      CATCH { default { $threw = True } }
    }

    expect($threw).to.be-falsy;
  }
}
