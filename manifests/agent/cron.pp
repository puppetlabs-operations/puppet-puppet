class puppet::agent::cron($manage_service = false) {
  include puppet::params

  cron { "puppet agent":
    command => "${puppet::params::puppet_cmd} agent --confdir ${puppet::params::puppet_confdir} --onetime --no-daemonize >/dev/null",
    minute  => fqdn_rand( 60 ),
  }

  class { "::puppet::agent::monitor": enable => false; }

  if $manage_service {
    service { "puppet_agent":
      name       => $puppet::params::agent_service,
      ensure     => stopped,
      enable     => false,
    }
  }
}
