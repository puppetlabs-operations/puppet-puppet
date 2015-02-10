require 'spec_helper'

openbsdfacts = {:operatingsystem => 'OpenBSD', :kernel => 'OpenBSD'}

describe "puppet::agent::service" do
  context "on OpenBSD" do
    let(:facts) { openbsdfacts }

    it { should_not contain_file('puppet_agent_service_conf') }
  end
end
