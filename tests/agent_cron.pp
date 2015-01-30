class { 'puppet::agent':
  method    => 'cron',
  frequency => 2,
}
