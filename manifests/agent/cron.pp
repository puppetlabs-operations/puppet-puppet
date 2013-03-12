class puppet::agent::cron($interval = 3, $manage_service = false) {
  include puppet::params

  cron { 'puppet agent':
    command => "${puppet::params::puppet_cmd} agent --confdir ${puppet::params::puppet_confdir} --onetime --no-daemonize >/dev/null",
    minute  => interval($interval, 60),
  }

  class { '::puppet::agent::monitor': enable => false; }

  if $manage_service {
    service { 'puppet_agent':
      name       => $puppet::params::agent_service,
      ensure     => stopped,
      enable     => false,
    }
  }
}
