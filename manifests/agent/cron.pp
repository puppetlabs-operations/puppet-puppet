class puppet::agent::cron(
  $enable = true,
) {
  include puppet::params

  if $enable {
    $ensure = present
  } else {
    $ensure = absent
  }

  cron { 'puppet agent':
    ensure  => $ensure,
    command => "${puppet::params::puppet_cmd} agent --confdir ${puppet::params::puppet_confdir} --onetime --no-daemonize >/dev/null",
    minute  => fqdn_rand(60),
  }
}
