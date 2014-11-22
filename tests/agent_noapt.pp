class { 'puppet::agent':
  method       => 'cron',
  manage_repos => false,
}
