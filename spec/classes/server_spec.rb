require 'spec_helper'

describe 'puppet::server' do
  context 'supported operating systems' do
    ['Debian', 'RedHat', 'CentOS'].each do |operatingsystem|

      describe "basic webrick puppet::server on #{operatingsystem}" do
        let(:params) {{
          :servertype => 'standalone',
          :manifest   => '/etc/puppet/manifests/site.pp',
          :ca         => true,
        }}
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

        it { should compile.with_all_deps }

        it { should contain_class('puppet::params') }
        it { should contain_class('puppet::server::config') }

        it { should contain_ini_setting('modulepath') }
        it do 
          should contain_service('puppetmaster').with({
            :ensure => "running"
          })
        end
      end
    end
  end
end
