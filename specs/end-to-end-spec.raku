use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;

describe 'signing up', {
  playwright-page(fixture => 'specs/fixtures/form.html');

  it 'greets the user after the form is submitted', -> $_ {
    .page.locator('#username').fill('Ada');
    .page.locator('#submit').click;

    expect(.page.locator('#welcome')).to.have-text('Welcome, Ada');
  }
}
