use lib 'lib';
use BDD::Behave;
use BDD::Behave::Playwright;
use BDD::Behave::Playwright::Diagnostics;
use BDD::Behave::Playwright::Session;

sub net-log-size(Str $dir --> Int) {
  return 0 unless $dir.IO.d;

  $dir.IO.dir(test => /^ "net-log-{$*PID}-" \d+ ".json" $/).map(*.s).sum;
}

sub remove-dir(Str $dir --> Nil) {
  if $dir.IO.d {
    .unlink for $dir.IO.dir;
    $dir.IO.rmdir;
  }
}

describe 'net-log-enabled', {
  it 'is off when PLAYWRIGHT_NET_LOG is unset', {
    temp %*ENV;
    %*ENV<PLAYWRIGHT_NET_LOG>:delete;

    expect(net-log-enabled()).to.be-falsy;
  }

  it 'is on when PLAYWRIGHT_NET_LOG is set', {
    temp %*ENV;
    %*ENV<PLAYWRIGHT_NET_LOG> = '1';

    expect(net-log-enabled()).to.be-truthy;
  }

  it 'prefers an explicit argument over PLAYWRIGHT_NET_LOG', {
    temp %*ENV;
    %*ENV<PLAYWRIGHT_NET_LOG> = '1';

    expect(net-log-enabled(False)).to.be-falsy;
  }
}

describe 'net-log-args', {
  my $dir = 'playwright-artifacts-net-log-args-spec';

  after-all {
    remove-dir($dir);
  }

  context 'when the net log is disabled', {
    let(:args, { net-log-args(:$dir, :!enabled) });

    it 'returns no arguments', {
      expect(args.elems).to.be(0);
    }
  }

  context 'when the net log is enabled', {
    let(:args, { net-log-args(:$dir, :enabled) });

    it 'returns one argument', {
      expect(args.elems).to.be(1);
    }

    it 'returns a log-net-log switch with a path under the artifacts folder', {
      expect(args[0].starts-with("--log-net-log={$dir.IO.absolute}/")).to.be-truthy;
    }

    it 'names the log file after the process id and a launch number', {
      expect(args[0]).to.match(/ "/net-log-{$*PID}-" \d+ ".json" $/);
    }

    it 'creates the artifacts folder', {
      args;

      expect($dir.IO.d).to.be-truthy;
    }
  }

  context 'when called twice in one process', {
    let(:first-args, { net-log-args(:$dir, :enabled) });
    let(:second-args, { net-log-args(:$dir, :enabled) });

    it 'returns a different log file path for each call', {
      expect(first-args()[0]).to.not.eq(second-args()[0]);
    }
  }
}

describe 'a playwright-page run with the net log enabled', {
  my $dir = 'playwright-artifacts-net-log-page-spec';

  playwright-page(fixture => 'specs/fixtures/hello.html', artifacts => $dir, :net-log);

  after-all {
    remove-dir($dir);
  }

  it 'writes a non-empty net log file in the artifacts folder', {
    expect(net-log-size($dir)).to.be-greater-than(0);
  }
}

describe 'a session browser with the net log enabled', {
  my $dir = 'playwright-artifacts-net-log-session-spec';

  let(:log-size, {
    configure(artifacts => $dir, :net-log);
    start-browser();
    stop-browser();

    net-log-size($dir);
  });

  after-all {
    configure();
    remove-dir($dir);
  }

  it 'leaves a non-empty net log file in the artifacts folder', {
    expect(log-size).to.be-greater-than(0);
  }
}
