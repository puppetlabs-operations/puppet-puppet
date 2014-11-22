require 'spec_helper_acceptance'

describe 'thin server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  context 'running on thin', :servertype => 'thin', :webserver => 'nginx' do
    it 'should run with no errors' do
      pp = <<-EOS
        class { "puppet::server":
          servertype   => 'thin',
          ca           => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe package('thin') do
      it { should be_installed.by('gem') }
    end

    describe service('thin-puppetmaster') do
      it { should be_enabled }
      it { should be_running }
    end

    it_behaves_like "basic working puppetmaster"
    it_behaves_like "nginx-based webserver"

  end
end
