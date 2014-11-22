require 'spec_helper_acceptance'

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on webrick/standalone', :server => 'webrick', :webserver => 'builtin' do
    it 'should run with no errors' do
      pp = <<-EOS
        class { 'puppet::server':
          servertype => 'standalone',
          ca         => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service('puppetmaster') do
      it { should be_enabled }
      it { should be_running }
    end

    # sanity checks to ensure the webrick setup doesn't bring in other services
    describe service('nginx') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe service('apache2') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe service('httpd') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe service('puppetserver') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    it_behaves_like 'basic working puppetmaster'

  end
end
