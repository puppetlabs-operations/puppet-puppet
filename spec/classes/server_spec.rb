require 'spec_helper'

shared_examples_for "all puppet master types" do
  it { should compile.with_all_deps }
  it { should contain_class('puppet::server') }
  it { should contain_class('puppet::package') }
  it { should contain_class('puppet::agent') }
  it { should contain_class('puppet::params') }
  it { should contain_class('puppet::server::config') }
end

shared_examples_for "basic puppetmaster config" do
  it { should contain_ini_setting('ca').with_value(true) }
  it { should contain_ini_setting('modulepath').with_value('/etc/puppet/environments/production/modules') }
  it { should contain_ini_setting('environmentpath').with_ensure('absent') }
end

shared_examples_for "basic puppetmaster environment config" do
  it { should contain_ini_setting('ca').with_value(true) }
  it { should contain_ini_setting('environmentpath').with_value('$confdir/environments') }
  it { should contain_ini_setting('modulepath').with_ensure('absent') }
end

describe 'puppet::server' do
  describe "webrick puppet::server" do
    let(:params) {{
      :servertype      => 'standalone',
      :manifest        => '/etc/puppet/manifests/site.pp',
      :modulepath      => ['/etc/puppet/environments/production/modules'],
      :environmentpath => '$confdir/environments',
      :ca              => true,
    }}
    shared_examples_for "all standalone masters" do
      it { should contain_class('puppet::server::standalone') }
    end

    context 'RedHat-derived Distros' do
      ['RedHat', 'CentOS'].each do |operatingsystem|
        context "#{operatingsystem}" do
          let(:facts) {{
            :osfamily        => 'redhat',
            :operatingsystem => operatingsystem,
          }}

          it_behaves_like "all puppet master types"
          it_behaves_like "all standalone masters"
          it_behaves_like "basic puppetmaster environment config"

          # RHEL-specific examples
          it { should contain_package('puppet-server') }
          it do
            should contain_service('puppetmaster').with({
              :ensure => "running"
            })
          end
        end
      end
    end

    context 'Debian-derived distros' do
      ['Debian','Ubuntu'].each do |operatingsystem|
        context "#{operatingsystem}" do
          let(:facts) {{
            :operatingsystem => operatingsystem,
            :osfamily        => 'debian',
            :lsbdistid       => operatingsystem,
            :lsbdistcodename => 'lolwut',
          }}

          it_behaves_like "all puppet master types"
          it_behaves_like "all standalone masters"
          it_behaves_like "basic puppetmaster environment config"

          # Debian-specific examples
          it { should contain_package('puppetmaster') }
          it do
            should contain_service('puppetmaster').with({
              :ensure => "running"
            })
          end
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
        it_behaves_like "all puppet master types"
        it_behaves_like "basic puppetmaster config"

        # Tests specific to passenger server
        it { should contain_class('puppet::passenger') }
        it { should contain_class('apache') }
        it { should contain_class('apache::mod::passenger') }

        # RHEL-family specific examples
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
  describe "unicorn puppet::server" do
    let(:params) {{
      :servertype   => 'unicorn',
      :storeconfigs => 'puppetdb',
      :manifest     => '/etc/puppet/manifests/site.pp',
      :modulepath   => ['/etc/puppet/environments/production/modules'],
      :ca           => true,
    }}
    context 'Debian' do
      let(:facts) {{
        :operatingsystem        => 'debian',
        :operatingsystemrelease => '7',
        :osfamily               => 'debian',
        :puppetversion          => '3.4.2',
        :concat_basedir         => '/foo',
        :kernel                 => 'linux',
        :lsbdistid              => 'debian',
        :lsbdistcodename        => 'wheezy',
      }}
      it_behaves_like "all puppet master types"
      it_behaves_like "basic puppetmaster config"

      it { should contain_package('puppetmaster') }

      # Tests specific to passenger server
      it { should contain_class('puppet::server::unicorn') }

      it do
        should contain_service('puppetmaster').with({
          :ensure => "stopped"
        })
        should contain_service('nginx').with({
          :ensure => "running"
        })
        should contain_service('unicorn_puppetmaster').with({
          :ensure => "running"
        })
      end
    end
  end
  describe "thin puppet::server" do
    let(:params) {{
      :servertype   => 'thin',
      :storeconfigs => 'puppetdb',
      :manifest     => '/etc/puppet/manifests/site.pp',
      :modulepath   => ['/etc/puppet/environments/production/modules'],
      :ca           => true,
    }}
    context 'Debian' do
      let(:facts) {{
        :operatingsystem        => 'debian',
        :operatingsystemrelease => '7',
        :osfamily               => 'debian',
        :puppetversion          => '3.4.2',
        :concat_basedir         => '/foo',
        :kernel                 => 'linux',
        :lsbdistid              => 'debian',
        :lsbdistcodename        => 'wheezy',
      }}
      it_behaves_like "all puppet master types"
      it_behaves_like "basic puppetmaster config"

      it { should contain_package('puppetmaster') }

      # Tests specific to passenger server
      it { should contain_class('puppet::server::thin') }

      it do
        should contain_service('puppetmaster').with({
          :ensure => "stopped"
        })
        should contain_service('nginx').with({
          :ensure => "running"
        })
        should contain_service('thin-puppetmaster').with({
          :ensure => "running"
        })
        should contain_file('/etc/thin.d/puppetmaster.yml')
      end
    end
  end
  describe "puppetserver puppet::server" do
    let(:params) {{
      :servertype      => 'puppetserver',
      :manifest        => '/etc/puppet/manifests/site.pp',
      :modulepath      => ['/etc/puppet/environments/production/modules'],
      :environmentpath => '$confdir/environments',
      :ca              => true,
    }}
    shared_examples_for "all puppetserver masters" do
      it { should contain_class('puppet::server::puppetserver') }
    end

    context 'RedHat-derived Distros' do
      ['RedHat', 'CentOS'].each do |operatingsystem|
        context "#{operatingsystem}" do
          let(:facts) {{
            :osfamily        => 'redhat',
            :operatingsystem => operatingsystem,
            :processorcount  => 4
          }}

          it_behaves_like "all puppet master types"
          it_behaves_like "all puppetserver masters"
          it_behaves_like "basic puppetmaster environment config"

          # RHEL-specific examples
          it { should contain_package('puppet-server') }
          it do
            should contain_service('puppetserver').with({
              :ensure => "running"
            })
            should contain_service('puppetmaster').with({
              :ensure => "stopped"
            })
          end
        end
      end
    end

    context 'Debian-derived distros' do
      ['Debian','Ubuntu'].each do |operatingsystem|
        context "#{operatingsystem}" do
          let(:facts) {{
            :operatingsystem => operatingsystem,
            :osfamily        => 'debian',
            :lsbdistid       => operatingsystem,
            :lsbdistcodename => 'lolwut',
          }}

          it_behaves_like "all puppet master types"
          it_behaves_like "all puppetserver masters"
          it_behaves_like "basic puppetmaster environment config"

          # Debian-specific examples
          it { should contain_package('puppetserver') }
          it do
            should contain_service('puppetserver').with({
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

end
