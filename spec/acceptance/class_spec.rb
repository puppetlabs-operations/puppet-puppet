require 'spec_helper_acceptance'

describe 'webrick puppetmaster' do

  context 'as documented in readme' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
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

    describe package('puppet') do
      it { should be_installed }
    end

    describe service('puppetmaster') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
