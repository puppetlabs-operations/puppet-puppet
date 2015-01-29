class puppet::agent::cron (
  $enable   = true,
  $run_noop = false,
  $interval = 3,
) {
  include puppet::params

  if $enable {
    $ensure = present
  } else {
    $ensure = absent
  }

  if $run_noop {
    $cmd = "${puppet::params::puppet_cmd} agent --confdir ${puppet::params::puppet_confdir} --onetime --no-daemonize --noop >/dev/null"
  } else {
    $cmd = "${puppet::params::puppet_cmd} agent --confdir ${puppet::params::puppet_confdir} --onetime --no-daemonize >/dev/null"
  }

  cron { 'puppet agent':
    ensure  => $ensure,
    command => $cmd,
    minute  => interval($interval, 60),
  }
}
