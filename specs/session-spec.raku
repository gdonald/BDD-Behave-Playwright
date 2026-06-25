use lib 'lib';
use WWW::Playwright;
use BDD::Behave;
use BDD::Behave::Playwright;
use BDD::Behave::Playwright::Session;

describe 'BDD::Behave::Playwright::Session lifecycle', {
  before-all {
    configure();
    start-browser();
  }

  before-each {
    open-page();
  }

  after-each {
    finish-page();
  }

  after-all {
    stop-browser();
  }

  it 'produces a live page from open-page', {
    expect(page).to.be-a(WWW::Playwright::Page);
  }

  it 'navigates and reads the document title through the page term', {
    page.goto(fixture-url('specs/fixtures/hello.html'));

    expect(page.title).to.eq('Hello');
  }
}

describe 'BDD::Behave::Playwright::Session teardown', {
  let(:after-finish, {
    configure();
    start-browser();
    open-page();
    finish-page();

    page.defined;
  });

  it 'clears the current page after finishing', {
    expect(after-finish).to.be-falsy;
  }

  it 'leaves no current page after stopping the browser', {
    after-finish;
    stop-browser();

    expect(page.defined).to.be-falsy;
  }
}
