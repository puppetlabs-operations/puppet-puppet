require 'spec_helper'

openbsdfacts = {:operatingsystem => 'OpenBSD'}

describe "puppet::server::config" do
  context "on OpenBSD" do
    let(:facts) { openbsdfacts }

    it { should contain_ini_setting('group').with_value('_puppet') }
    it { should contain_ini_setting('user').with_value('_puppet') }
  end
end
