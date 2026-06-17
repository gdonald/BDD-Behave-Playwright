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

  it 'awaits an element revealed asynchronously', -> $_ {
    .page.locator('#go-async').click;
    expect(.page.locator('#async-status')).to.be-visible;
  }

  it 'be-visible negates for a hidden element', -> $_ {
    expect(.page.locator('#status')).not.to.be-visible(timeout => 0.3);
  }
}
