require 'spec_helper'

shared_examples_for "all puppet master types" do
  it { should compile.with_all_deps }
  it { should contain_class('puppet::server') }
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
  it { should contain_ini_setting('basemodulepath').with_value('/etc/puppet/modules:/usr/share/puppet/modules') }
  it { should contain_ini_setting('modulepath').with_ensure('absent') }
end

PuppetSpecFacts.facts_for_platform_by_name(["Debian_wheezy_7.7_amd64_3.7.2_structured", "Ubuntu_precise_12.04_amd64_PE-3.3.2_stringified", "Ubuntu_trusty_14.04_amd64_PE-3.3.2_stringified"]).each do |name, facthash|
  describe "puppet::server" do
    let(:facts) { facthash }

    context "running on #{name}" do
      ['standalone','passenger','unicorn','thin'].each do |server_type|
        context "servertype => #{server_type}" do
          let(:params) {{
            :servertype   => server_type,
            :storeconfigs => 'puppetdb',
            :environmentpath => '$confdir/environments',
            :basemodulepath => ['/etc/puppet/modules', '/usr/share/puppet/modules'],
            :default_manifest => 'site.pp',
            :ca           => true,
          }}

          case facthash['osfamily']
          when 'RedHat'
            puppetmaster_package = 'puppet-server'
          when 'Debian'
            puppetmaster_package = 'puppetmaster'

          end
          it_behaves_like "all puppet master types"
          it_behaves_like "basic puppetmaster environment config"

          case server_type
            when 'standalone'
            it {
              should contain_class('puppet::server::standalone')
              should contain_service('puppetmaster').with({ :ensure => "running" })
              should contain_package(puppetmaster_package)
            }

            when 'passenger'
              it {
                should contain_class('puppet::server::passenger')
                should contain_class('apache')
                should contain_class('apache::mod::passenger')
              }

            when 'unicorn'
              it {
                should contain_class('puppet::server::unicorn')
                should contain_service('puppetmaster').with({:ensure => "stopped"})
                should contain_service('nginx').with({:ensure => "running"})
                should contain_service('unicorn_puppetmaster').with({:ensure => "running"})
              }
            when 'thin'
              it {
                should contain_class('puppet::server::thin')
                should contain_service('puppetmaster').with({ :ensure => "stopped" })
                should contain_service('nginx').with({:ensure => "running"})
                should contain_service('thin-puppetmaster').with({:ensure => "running"})
                should contain_file('/etc/thin.d/puppetmaster.yml')
              }
          end
        end
      end

      context "manage_package => false" do
        let(:params) {{ :manage_package => false }}
        case facthash['osfamily']
          when 'RedHat'
            it { should_not contain_package('puppet-server') }
          when 'Debian'
            it { should_not contain_package('puppetmaster') }
        end
      end
    end
  end
end
