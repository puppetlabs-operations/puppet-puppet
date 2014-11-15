require 'spec_helper_acceptance'

describe 'passenger server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on passenger' do
    it 'should run with no errors', :servertype => 'passenger', :webserver => 'apache' do
      pp = <<-EOS
        class { "puppet::server":
          servertype   => 'passenger',
          ca           => true,
          servername   => $::hostname,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe port(8140) do
      it {
        should be_listening
      }
    end
  end
end
