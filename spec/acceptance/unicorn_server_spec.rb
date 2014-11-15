require 'spec_helper_acceptance'

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running on unicorn' do
    it 'should run with no errors', :servertype => 'unicorn', :webserver => 'nginx' do
      pp = <<-EOS
        class { "puppet::server":
          servertype   => 'unicorn',
          ca           => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  describe command('puppet agent --test --server puppet') do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should_not match /Forbidden request:/ }
    its(:stderr) { should_not match /Error:/ }
  end

    describe package('nginx') do
      it {
        should be_installed
      }
    end

    describe service('nginx') do
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
