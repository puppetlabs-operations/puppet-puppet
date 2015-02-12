require 'spec_helper'

describe 'puppet' do
  let(:facts) {
    {
      :operatingsystem => 'OpenBSD',
      :domain => 'example.com',
    }
  }

  context "with srv records enabled" do
    let(:params) { {:use_srv_records => true} }

      it { should contain_ini_setting('use_srv_records').with_value(true) }
      it { should contain_ini_setting('srv_domain').with_value('example.com') }
  end

  context "with srv records disabled" do
    let(:params) { {:use_srv_records => false} }

      it { should contain_ini_setting('use_srv_records').with_ensure('absent') }
      it { should contain_ini_setting('srv_domain').with_ensure('absent') }
  end

  PuppetSpecFacts.facts_for_platform_by_name([
    "Debian_wheezy_7.7_amd64_3.7.2_structured",
    "Ubuntu_precise_12.04_amd64_PE-3.3.2_stringified",
    "Ubuntu_trusty_14.04_amd64_PE-3.3.2_stringified"]).each do |name, facthash|

    context 'supported operating systems' do
      ['Debian', 'RedHat', 'CentOS'].each do |operatingsystem|
        describe "puppet class without any parameters on #{operatingsystem}" do
          let(:params) {{ }}
          let(:facts) { facthash }

          it { should compile.with_all_deps }
          it { should contain_class('puppet::params') }
        end
      end
    end

    context 'unsupported operating system' do
      describe 'puppet class without any parameters on OpenVMS' do
        let(:facts) {{
          :operatingsystem => 'OpenVMS',
        }}

        it { expect { should contain_package('puppet') }.to raise_error(Puppet::Error, /Sorry, OpenVMS is not supported/) }
      end
    end
  end
end
