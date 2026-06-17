use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'fixture-url', {
  it 'turns a filesystem path into an absolute file URL', {
    expect(fixture-url('specs/fixtures/hello.html')).to.eq('file://' ~ 'specs/fixtures/hello.html'.IO.absolute);
  }
}

describe 'Playwright page lifecycle', {
  playwright-page(fixture => 'specs/fixtures/hello.html');

  it 'navigates to the fixture and exposes a usable page', -> $_ {
    expect(.page.locator('#greeting').text-content).to.eq('Hello, world');
  }
}
