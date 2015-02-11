require 'spec_helper'

describe "puppet::config" do
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
end
