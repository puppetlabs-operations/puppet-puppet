class MCollective::Agent::Deploy < MCollective::RPC::Agent

  metadata :name        => 'Puppet Deploy, now with Mcollective!',
           :description => 'Run puppet_deploy.rb on all masters',
           :author      => 'Adrien Thebo',
           :license     => 'Do whatever the fuck you want',
           :url         => 'http://purple.com',
           :version     => '0.0.1',
           :timeout     => 300


  def startup_hook
    @executable = @config.pluginconf['deploy.puppet.cmd'] || '/usr/local/bin/puppet_deploy.rb'
  end

  action :puppet do

    argv = [@executable]
    argv << '--parallel'     if request[:parallel]
    argv << '--no-librarian' unless request[:librarian]

    cmd = argv.join(' ')

    reply[:status] = run(cmd, :stdout => :out, :stderr => :err)
  end
end
