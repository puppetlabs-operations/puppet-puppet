class puppet::agent::cron($interval = 1) {
  include puppet::params

  cron { "puppet agent":
    command => "${puppet::params::puppet_cmd} agent --onetime --no-daemonize >/dev/null",
    minute  => fqdn_rand_array($interval, 60),
  }

  class { "::puppet::agent::monitor": enable => false; }

  service { "puppet_agent":
    name       => $puppet::params::agent_service,
    ensure     => stopped,
    enable     => false,
  }
}
