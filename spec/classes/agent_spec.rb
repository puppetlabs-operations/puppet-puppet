require 'spec_helper'

shared_examples 'agent examples' do
  it { should contain_class('puppet::agent') }
  it { should compile.with_all_deps }
  it { should contain_ini_setting('report_server').with_value('puppet_reports.example.com') }
  it { should contain_ini_setting('server').with_value('puppet.example.com') }
  it { should contain_ini_setting('pluginsync').with_value(true) }
  it { should contain_package('puppet') }
end

PuppetSpecFacts.facts_for_platform_by_name(["Debian_wheezy_7.7_amd64_3.7.2_structured", "CentOS_5.11_x86_64_3.7.1_structured", "FreeBSD_10.0-RELEASE_amd64_3.6.2_structured"]).each do |name, facthash|
describe "puppet::agent" do
    let(:facts) { facthash }

    context "running on #{name}" do
      [true, false].each do |manage_repos|

        context "when manage_repos => #{manage_repos}" do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :manage_repos  => manage_repos,
          }}

          case facthash['osfamily']
          when 'RedHat'
            it_behaves_like "agent examples"
            it {
              is_expected.to contain_class('Puppet::Package::Repository') if manage_repos == true
              is_expected.to contain_yumrepo('puppetlabs-products') if manage_repos == true
              is_expected.to_not contain_yumrepo('puppetlabs-products') if manage_repos == false
              is_expected.to_not contain_apt__source('puppetlabs')
            }
          when 'Debian'
            it_behaves_like "agent examples"
            it { is_expected.to contain_class('Puppet::Package::Repository') if manage_repos == true }
            it { should_not contain_class('puppetlabs_yum') }
            if manage_repos == true
            it {
              is_expected.to contain_class('puppetlabs_apt')
              is_expected.to contain_apt__source('puppetlabs')
            }
            elsif manage_repos == false
              it { is_expected.to_not contain_class('puppetlabs_apt') }
            end
          when 'FreeBSD'
            if manage_repos == false
              it {
                is_expected.to_not contain_class('puppetlabs_apt')
                is_expected.to_not contain_class('puppetlabs_yum')
                is_expected.to compile.with_all_deps
              }
            end
          end
        end
      end
      ['service','cron','only_service'].each do |agent_method|
        manage_repos = false if facthash['osfamily'] == 'FreeBSD'
        context "method => #{agent_method}" do
          describe "agent configuration on #{facthash["osfamily"]}" do
            let(:params) {{
              :server        => 'puppet.example.com',
              :report_server => 'puppet_reports.example.com',
              :method        => agent_method,
              :manage_repos  => manage_repos,
            }}

            it_behaves_like "agent examples"
            case agent_method
            when 'service'
              it { should contain_service('puppet_agent').with({ :ensure => "running" }) }
              it { should contain_cron('puppet agent') }
            when 'cron'
              it { should contain_service('puppet_agent').with({ :ensure => "stopped" }) }
              it { should contain_cron('puppet agent') }
            when 'only_service'
              it { should contain_service('puppet_agent').with({ :ensure => "running" }) }
              it { should_not contain_cron('puppet agent') }
            end
          end
        end
      end
    end
  end
end

