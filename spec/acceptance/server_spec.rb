require 'spec_helper_acceptance'
def cleanup_server()
  cleanup_pp = <<-EOS
    $services = [ 'apache2', 'httpd', 'puppetmaster', 'unicorn_puppetmaster' ]
    service { $services: ensure => 'stopped' }
    $packages = [ 'nginx', 'apache2', 'httpd', 'puppetmaster', 'puppetmaster-common', 'ruby-passenger']
    package { $packages: ensure => 'absent' }
  EOS

  apply_manifest(cleanup_pp, :catch_failures => false)
  apply_manifest(cleanup_pp, :catch_failures => false)
  shell("killall apache2 httpd nginx puppetmaster unicorn", :acceptable_exit_codes => [0,1] )
end

describe 'server', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  before(:all) do
    cleanup_server()
  end

  context 'running on webrick/standalone' do
    after(:all) do
      cleanup_server()
    end
    it 'should run with no errors' do
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

  context 'running on passenger' do
    after(:all) do
      cleanup_server()
    end

    it 'should run with no errors' do
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

  context 'running on unicorn' do
    after(:all) do
      cleanup_server()
    end

    it 'should run with no errors' do
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
