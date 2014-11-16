require 'spec_helper_acceptance'

describe 'passenger server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on passenger', :servertype => 'passenger', :webserver => 'apache' do
    it 'should run with no errors' do
      pp = <<-EOS
        class { 'puppet::server':
          servertype => 'passenger',
          ca         => true,
          servername => $::hostname,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
    it_behaves_like 'basic working puppetmaster'

    # sanity checks to ensure the passenger setup doesn't bring in other services
    describe service('nginx') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe service('puppetmaster') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
    describe service('puppetserver') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end
end
