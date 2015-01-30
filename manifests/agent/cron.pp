class puppet::agent::cron (
  $enable    = true,
  $run_noop  = false,
  $frequency = 1
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

  $interval = 60 / $frequency
  $random_offset = fqdn_rand($interval)
  $cron_schedule = $frequency.map |$value| { ($value * $interval) + $random_offset}

  cron { 'puppet agent':
    ensure  => $ensure,
    command => $cmd,
    minute  => $cron_schedule,
  }
}
