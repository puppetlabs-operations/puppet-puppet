require 'spec_helper_acceptance'

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on puppetserver', :servertype => 'puppetserver', :webserver => 'puppetserver' do
    it 'should run with no errors' do
      pp = <<-EOS
        class { 'puppet::server':
          servertype => 'puppetserver',
          ca         => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it_behaves_like "basic working puppetmaster"
    it_behaves_like "puppetserver-based master"

  end
end
