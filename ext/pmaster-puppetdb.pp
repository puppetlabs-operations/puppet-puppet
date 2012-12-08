class { 'puppet::agent':
  server        => 'puppet.example.com',
  report_server => 'puppet.example.com',
  ca_server     => 'puppet.example.com',
  method        => 'service',
  custom_repo   => false,
  environment   => 'development',
} -> 
class { 'puppet::server':
  modulepath         => '$confdir/env/$environment/modules:$confdir/modules',
  config_version_cmd => false,
  storeconfigs       => 'puppetdb',
  servertype         => 'passenger',
  monitor_server     => false,
  backup_server      => false,
  manifest           => '/etc/puppet/manifests/site.pp',
} -> 
class { 'puppetdb':
  database           => 'embedded',
  listen_address     => '0.0.0.0',
  ssl_listen_address => '0.0.0.0',
} -> 
class { 'puppetdb::master::config': }
