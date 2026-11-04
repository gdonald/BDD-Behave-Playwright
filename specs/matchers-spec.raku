use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'Playwright matchers', {
  playwright-page(fixture => 'specs/fixtures/hello.html');

  it 'be-visible passes for a visible element', -> $_ {
    expect(.page.locator('#greeting')).to.be-visible;
  }

  it 'be-hidden passes for a hidden element', -> $_ {
    expect(.page.locator('#status')).to.be-hidden;
  }

  it 'be-enabled passes for an enabled input', -> $_ {
    expect(.page.locator('#name')).to.be-enabled;
  }

  it 'be-disabled passes for a disabled input', -> $_ {
    expect(.page.locator('#locked')).to.be-disabled;
  }

  it 'be-checked passes for a checked checkbox', -> $_ {
    expect(.page.locator('#agree')).to.be-checked;
  }

  it 'have-text passes when the text matches', -> $_ {
    expect(.page.locator('#greeting')).to.have-text('Hello, world');
  }

  it 'have-value passes after filling an input', -> $_ {
    .page.locator('#name').fill('Ada');
    expect(.page.locator('#name')).to.have-value('Ada');
  }

  it 'have-attribute passes when the attribute matches', -> $_ {
    expect(.page.locator('#name')).to.have-attribute('type', 'text');
  }

  it 'have-count passes for the expected number of matches', -> $_ {
    expect(.page.locator('button')).to.have-count(2);
  }

  it 'have-css passes when the page has the selector', -> $_ {
    expect(.page).to.have-css('#greeting');
  }

  it 'have-title passes when the document title matches', -> $_ {
    expect(.page).to.have-title('Hello');
  }

  it 'have-current-path matches the path of the current URL', -> $_ {
    expect(.page).to.have-current-path('specs/fixtures/hello.html'.IO.absolute);
  }

  it 'have-current-path matches the full URL with the url option', -> $_ {
    expect(.page).to.have-current-path(fixture-url('specs/fixtures/hello.html'), url => True);
  }

  it 'awaits an element revealed asynchronously', -> $_ {
    .page.locator('#go-async').click;
    expect(.page.locator('#async-status')).to.be-visible;
  }

  it 'be-visible negates for a hidden element', -> $_ {
    expect(.page.locator('#status')).not.to.be-visible(timeout => 0.3);
  }

  context 'when the locator matches no element', {
    it 'have-text fails with the empty text', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page.locator('p.missing')).to.have-text('anything', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have text anything, but text was ""' $/);
    }

    it 'have-value fails with the empty value', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page.locator('input.missing')).to.have-value('Ada', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have value Ada, but value was ""' $/);
    }

    it 'have-attribute fails with a missing attribute', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page.locator('input.missing')).to.have-attribute('type', 'text', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have attribute "type" text, but the attribute was missing' $/);
    }
  }

  context 'when the element lacks the attribute', {
    it 'have-attribute fails with a missing attribute', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page.locator('#greeting')).to.have-attribute('alt', 'Grace Hopper', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have attribute "alt" Grace Hopper, but the attribute was missing' $/);
    }
  }

  context 'when the attribute has a different value', {
    it 'have-attribute fails with the actual value', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page.locator('#name')).to.have-attribute('type', 'checkbox', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have attribute "type" checkbox, but it was "text"' $/);
    }
  }

  context 'when the page has a different title', {
    it 'have-title fails with the quoted expected title', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page).to.have-title('Companies', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have title "Companies", but title was "Hello"' $/);
    }

    it 'have-title fails with the expected pattern for a regex', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page).to.have-title(/Companies/, timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have title /Companies/, but title was "Hello"' $/);
    }
  }

  context 'when the page has a different current path', {
    it 'have-current-path fails with the quoted expected path', -> $_ {
      my $page = .page;

      my $failure = capture-failures({
        expect($page).to.have-current-path('/companies', timeout => 0.3);
      }).head;

      expect($failure.message).to.match(/'to have current path "/companies", but path was "' .+ '"' $/);
    }
  }
}
