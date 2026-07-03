use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'fixture-url', {
  it 'turns a filesystem path into an absolute file URL', {
    expect(fixture-url('specs/fixtures/hello.html')).to.eq('file://' ~ 'specs/fixtures/hello.html'.IO.absolute);
  }
}

describe 'headless-from-env', {
  it 'runs headless when SHOW_CHROME is unset', {
    expect(headless-from-env({})).to.be-truthy;
  }

  it 'runs headed when SHOW_CHROME is set', {
    expect(headless-from-env({ SHOW_CHROME => '1' })).to.be-falsy;
  }

  it 'stays headless when SHOW_CHROME is zero', {
    expect(headless-from-env({ SHOW_CHROME => '0' })).to.be-truthy;
  }

  it 'stays headless for the words false, no, and off', {
    aggregate-failures {
      expect(headless-from-env({ SHOW_CHROME => 'false' })).to.be-truthy;
      expect(headless-from-env({ SHOW_CHROME => 'no' })).to.be-truthy;
      expect(headless-from-env({ SHOW_CHROME => 'off' })).to.be-truthy;
    }
  }

  it 'ignores surrounding whitespace and case', {
    expect(headless-from-env({ SHOW_CHROME => ' OFF ' })).to.be-truthy;
  }
}

describe 'Playwright page lifecycle', {
  playwright-page(fixture => 'specs/fixtures/hello.html');

  it 'navigates to the fixture and exposes a usable page', -> $_ {
    expect(.page.locator('#greeting').text-content).to.eq('Hello, world');
  }
}

describe 'visiting paths against a base url', {
  playwright-page(base-url => fixture-url('specs/fixtures'));

  it 'navigates to a path beneath the base url', -> $_ {
    visit('/hello.html');
    expect(.page.locator('#greeting').text-content).to.eq('Hello, world');
  }

  it 'navigates to an absolute url unchanged', -> $_ {
    visit(fixture-url('specs/fixtures/hello.html'));
    expect(.page.locator('#greeting').text-content).to.eq('Hello, world');
  }
}

describe 'goto', {
  playwright-page(fixture => 'specs/fixtures/hello.html');

  it 'navigates the current page directly to a url', -> $_ {
    goto(fixture-url('specs/fixtures/responsive.html'));
    expect(.page.locator('#wide')).to.be-visible;
  }
}

describe 'visiting against a computed base url', {
  playwright-page(base-url => { fixture-url('specs/fixtures') });

  it 'resolves a callable base url at navigation time', -> $_ {
    visit('/hello.html');
    expect(.page.locator('#greeting').text-content).to.eq('Hello, world');
  }
}

describe 'a page in a context with a narrow viewport', {
  playwright-page(
    fixture => 'specs/fixtures/responsive.html',
    context => { viewport => { width => 400, height => 800 } });

  it 'applies the context options to the page', -> $_ {
    expect(.page.locator('#narrow')).to.be-visible;
  }
}

describe 'a page in a context with a dark color scheme', {
  playwright-page(
    fixture => 'specs/fixtures/responsive.html',
    context => { color-scheme => 'dark' });

  it 'applies the color scheme to the page', -> $_ {
    expect(.page.locator('#dark')).to.be-visible;
  }
}
