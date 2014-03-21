require 'spec_helper'

describe 'puppet::server' do
  describe "webrick puppet::server" do
    let(:params) {{
      :servertype => 'standalone',
      :manifest   => '/etc/puppet/manifests/site.pp',
      :modulepath => ['/etc/puppet/environments/production/modules'],
      :ca         => true,
    }}
    context 'CentOS/RedHat' do
      ['RedHat', 'CentOS'].each do |operatingsystem|
        let(:facts) {{ :operatingsystem => operatingsystem }}
        it { should contain_class('puppet::server') }
        it { should contain_class('puppet::server::standalone') }
        it { should contain_class('puppet::package') }
        it { should contain_class('puppet::agent') }


        it { should compile.with_all_deps }
        it { should contain_class('puppet::params') }
        it { should contain_class('puppet::server::config') }
        it { should contain_ini_setting('modulepath').with_value('/etc/puppet/environments/production/modules') }
        it { should contain_ini_setting('ca').with_value(true) }

        it { should contain_package('puppet-server') }
        it do
          should contain_service('puppetmaster').with({
            :ensure => "running"
          })
        end
      end
    end
    context 'Debian/Ubuntu' do
      ['Debian','Ubuntu'].each do |operatingsystem|
        let(:facts) {{ :operatingsystem => operatingsystem }}

        it { should compile.with_all_deps }
        it { should contain_class('puppet::params') }
        it { should contain_class('puppet::server::config') }
        it { should contain_ini_setting('modulepath').with_value('/etc/puppet/environments/production/modules') }
        it { should contain_ini_setting('ca').with_value(true) }

        it { should contain_package('puppetmaster') }

        it do
          should contain_service('puppetmaster').with({
            :ensure => "running"
          })
        end
      end
    end
  end
  describe "passenger puppet::server" do
    let(:params) {{
      :servertype   => 'passenger',
      :storeconfigs => 'puppetdb',
      :manifest     => '/etc/puppet/manifests/site.pp',
      :modulepath   => ['/etc/puppet/environments/production/modules'],
      :ca           => true,
    }}
    context 'CentOS/RedHat' do
      ['RedHat', 'CentOS'].each do |operatingsystem|
        let(:facts) {{ 
          :operatingsystem => operatingsystem,
          :operatingsystemrelease => '6',
          :osfamily => 'redhat',
          :puppetversion => '3.4.2',
          :concat_basedir => '/foo'
        }}
        it { should contain_class('puppet::server') }
        it { should contain_class('puppet::package') }
        it { should contain_class('puppet::agent') }
        it { should contain_class('puppet::passenger') }


        it { should compile.with_all_deps }
        it { should contain_class('puppet::params') }
        it { should contain_class('puppet::server::config') }
        it { should contain_ini_setting('modulepath').with_value('/etc/puppet/environments/production/modules') }
        it { should contain_ini_setting('ca').with_value(true) }

        it { should contain_package('puppet-server') }
        it do
          should contain_service('httpd').with({
            :ensure => "running"
          })
          should contain_service('puppetmaster').with({
            :ensure => "stopped"
          })
        end
      end
    end
  end
end
