require 'spec_helper_acceptance'

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on unicorn', :servertype => 'unicorn', :webserver => 'nginx' do
    it 'should run with no errors' do
      pp = <<-EOS
        class { 'puppet::server':
          servertype => 'unicorn',
          ca         => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it_behaves_like "basic working puppetmaster"
    it_behaves_like "nginx-based webserver"

  end
end
