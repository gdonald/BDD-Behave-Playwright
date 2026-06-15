use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;
use WWW::Playwright;

describe 'BDD::Behave::Playwright distribution', {
  it 'loads the module', {
    expect(BDD::Behave::Playwright.^name).to.eq('BDD::Behave::Playwright');
  }

  it 'exposes a defined distribution version', {
    expect(BDD::Behave::Playwright.dist-version.defined).to.be-truthy;
  }

  it 'resolves the BDD::Behave dependency', {
    expect(BDD::Behave.^name).to.eq('BDD::Behave');
  }

  it 'resolves the WWW::Playwright dependency', {
    expect(WWW::Playwright.^name).to.eq('WWW::Playwright');
  }
};
