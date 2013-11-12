# Install the puppetdb terminus. Puppetdb configuration should occur elsewhere.
class puppet::storeconfig::puppetdb(
  $server = 'localhost',
  $port   = '8081',
) {
  include puppet::params

  # ---
  # PupeptDB backend settings
  Ini_setting {
    notify => Class['puppet::server'],
  }

  ini_setting { 'storeconfigs_backend':
    ensure  => 'present',
    path    => $puppet::params::puppet_conf,
    section => 'master',
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }

  ini_setting { 'puppetdb_server':
    ensure  => 'present',
    path    => "${::puppet::params::puppet_confdir}/puppetdb.conf",
    section => 'main',
    setting => 'server',
    value   => $server,
  }

  ini_setting { 'puppetdb_port':
    ensure  => 'present',
    path    => "${::puppet::params::puppet_confdir}/puppetdb.conf",
    section => 'main',
    setting => 'port',
    value   => $port,
  }

  package { 'puppetdb-terminus':
    ensure => present,
    notify => Class['puppet::server'],
  }
}
