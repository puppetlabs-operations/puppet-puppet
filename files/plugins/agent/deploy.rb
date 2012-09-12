class MCollective::Agent::Deploy < MCollective::RPC::Agent

  metadata :name        => 'Puppet Deploy, now with Mcollective!',
           :description => 'Run puppet_deploy.rb on all masters',
           :author      => 'Adrien Thebo',
           :license     => 'Do whatever the fuck you want',
           :url         => 'http://purple.com',
           :version     => '0.0.1',
           :timeout     => 300


  def startup_hook
    @puppet_cmd = @config.pluginconf['deploy.puppet.cmd'] || '/usr/local/bin/puppet_deploy.rb --parallel'
  end

  action :puppet do
    reply[:status] = run(@puppet_cmd, :stdout => :out, :stderr => :err)
  end
end
