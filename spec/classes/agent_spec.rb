require 'spec_helper'

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

        it { should contain_class('puppet::package') }
        it { should contain_class('puppet::agent') }

        it { should compile.with_all_deps }
        it { should contain_ini_setting('report_server').with_value('puppet_reports.example.com') }
        it { should contain_ini_setting('server').with_value('puppet.example.com') }
        it { should contain_ini_setting('pluginsync').with_value(true) }

        it { should contain_package('puppet') }
        it do
          should contain_service('puppet_agent').with({
            :ensure => "running"
          })
        end
      end
    end
  end
end
