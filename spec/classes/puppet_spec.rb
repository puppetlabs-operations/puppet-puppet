require 'spec_helper'

PuppetSpecFacts.facts_for_platform_by_name([
  "Debian_wheezy_7.7_amd64_3.7.2_structured",
  "Ubuntu_precise_12.04_amd64_PE-3.3.2_stringified",
  "Ubuntu_trusty_14.04_amd64_PE-3.3.2_stringified"]).each do |name, facthash|

  describe 'puppet' do
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
