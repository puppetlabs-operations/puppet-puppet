require 'spec_helper'

shared_examples 'agent examples' do
  it { should contain_class('puppet::package') }
  it { should contain_class('puppet::agent') }
  it { should compile.with_all_deps }
  it { should contain_ini_setting('report_server').with_value('puppet_reports.example.com') }
  it { should contain_ini_setting('server').with_value('puppet.example.com') }
  it { should contain_ini_setting('pluginsync').with_value(true) }
  it { should contain_package('puppet') }
end

describe 'puppet::agent' do
  describe "sample agent configuration from documentation" do
    let(:params) {{
      :server        => 'puppet.example.com',
      :report_server => 'puppet_reports.example.com',
      :method        => 'service',
    }}
    context 'CentOS, RedHat, Debian, Ubuntu' do
      ['RedHat', 'CentOS', 'Debian', 'Ubuntu'].each do |operatingsystem|

        osfamily   = 'Redhat'  if ['RedHat', 'CentOS'].include? operatingsystem
        osfamily ||= 'Debian'

        let(:facts) {{
          :osfamily        => osfamily,
          :operatingsystem => operatingsystem,
          :lsbdistid       => operatingsystem,
          :lsbdistcodename => 'lolwut'
        }}
        context 'running as service' do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :method        => 'service',
          }}
          it_behaves_like "agent examples"
          it do
            should contain_service('puppet_agent').with({
              :ensure => "running"
            })
            should contain_cron('puppet agent')
          end
        end
        context 'method => "only_service"' do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :method        => 'only_service',
          }}
          it_behaves_like "agent examples"
          it do
            should contain_service('puppet_agent').with({
              :ensure => "running"
            })
            should_not contain_cron('puppet agent')
          end
        end
        context 'method => "none"' do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :method        => 'only_service',
          }}
          it_behaves_like "agent examples"
          it do
            should contain_service('puppet_agent').with({
              :ensure => "running"
            })
            should_not contain_cron('puppet agent')
          end
        end
        context 'method => "cron"' do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :method        => 'cron',
          }}
          it_behaves_like "agent examples"
          it do
            should_not contain_service('puppet_agent').with({
              :ensure => "running"
            })
            should contain_cron('puppet agent').with_command(/puppet agent/)
          end
        end
        context 'manage_repos => false' do
          let(:params) {{
            :server        => 'puppet.example.com',
            :report_server => 'puppet_reports.example.com',
            :manage_repos  => false,
          }}
          it_behaves_like "agent examples"
          it do
            should contain_service('puppet_agent')
            should contain_cron('puppet agent').with_command(/puppet agent/)
            should_not contain_yumrepo('puppetlabs-products')
            should_not contain_apt__source('puppetlabs')
          end
        end

      end
    end
  end
end
