require 'spec_helper_acceptance'

describe 'basic puppet environment' do
  hosts.each do |host|
    describe package('puppet') do
      it { should be_installed }
    end
 end
end

describe 'webrick puppetmaster' do
  describe 'server as documented in readme' do
    standalone_masters = hosts_as :standalone_master
    standalone_masters.each do |host|
      # Using puppet_apply as a helper
      it 'should configure standalone server with no errors' do
        pp = <<-EOS
          class { "puppet::server":
          servertype   => 'standalone',
          manifest     => '/etc/puppet/manifests/site.pp',
          ca           => true,
        }
        EOS

        # Run it twice and test for idempotency
        expect(apply_manifest(pp).exit_code).to_not eq(1)
        expect(apply_manifest(pp).exit_code).to eq(0)
      end

      describe service('puppetmaster') do
        it { should be_enabled }
        it { should be_running }
      end
    end
    standalone_master_agents = hosts_as :standalone_master_agents
    standalone_master_agents.each do |host|
      it 'should configure agent with no errors' do
        pp = <<-EOS
         class { 'puppet::agent':
         server        => 'ubuntu-server-12042-x64-master',
         report_server => 'ubuntu-server-12042-x64-master',
         method        => 'service',
        }
        EOS
        # Run it twice and test for idempotency
        expect(apply_manifest(pp).exit_code).to_not eq(1)
        expect(apply_manifest(pp).exit_code).to eq(0)

      end
      # Connect agent to master
    end
  end
end
