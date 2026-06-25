use lib 'lib';
use BDD::Behave;
use BDD::Behave::Configuration;
use BDD::Behave::Playwright;
use BDD::Behave::Playwright::Session;

constant Configuration = BDD::Behave::Configuration::Configuration;
constant PageHelper    = BDD::Behave::Playwright::Session::PageHelper;

describe 'BDD::Behave::Playwright.install', {
  let(:config, {
    my $cfg = Configuration.new;
    BDD::Behave::Playwright.install($cfg, :type<system>);
    $cfg;
  });

  for <before-all before-each after-each after-all> -> $phase {
    context "the $phase phase", {
      let(:hooks, { config.hooks-for($phase).list });

      it 'registers exactly one config hook', {
        expect(hooks.elems).to.eq(1);
      }

      it 'filters the hook to type system', {
        expect(hooks[0].meta<type>).to.eq('system');
      }
    }
  }

  context 'the page helper', {
    let(:includes, { config.includes.list });

    it 'registers exactly one helper', {
      expect(includes.elems).to.eq(1);
    }

    it 'registers the PageHelper class', {
      expect(includes[0].class === PageHelper).to.be-truthy;
    }

    it 'filters the helper include to type system', {
      expect(includes[0].meta<type>).to.eq('system');
    }

    it 'has no page before one is opened', {
      expect(PageHelper.new.page.defined).to.be-falsy;
    }
  }

  context 'with a custom type', {
    let(:custom, {
      my $cfg = Configuration.new;
      BDD::Behave::Playwright.install($cfg, :type<feature>);
      $cfg;
    });

    it 'tags the hooks with the given type', {
      expect(custom.hooks-for('before-each')[0].meta<type>).to.eq('feature');
    }
  }
}
