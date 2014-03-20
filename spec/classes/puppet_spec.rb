require 'spec_helper'

describe 'puppet' do
  context 'supported operating systems' do
    ['Debian', 'RedHat', 'CentOS'].each do |operatingsystem|
      describe "puppet class without any parameters on #{operatingsystem}" do
        let(:params) {{ }}
        let(:facts) {{
          :operatingsystem => operatingsystem,
        }}

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
