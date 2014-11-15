require 'spec_helper_acceptance'

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on webrick/standalone' do
    it 'should run with no errors', :server => 'webrick', :webserver => 'builtin' do
      pp = <<-EOS
        class { "puppet::server":
          servertype   => 'standalone',
          ca           => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service('puppetmaster') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe port(8140) do
      it {
        should be_listening
      }
    end
  end

end
