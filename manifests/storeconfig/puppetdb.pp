# Install the puppetdb terminus. Puppetdb configuration should occur elsewhere.
class puppet::storeconfig::puppetdb(
  $server = 'localhost',
  $port   = '8081',
) {
  include puppet::params

  file { "${::puppet::params::puppet_confdir}/puppetdb.conf":
    ensure  => present,
    mode    => 0644,
    owner   => 'puppet',
    group   => 'puppet',
    content => template('puppet/puppetdb.conf.erb'),
    notify => Class['puppet::server'],
  }

  package { 'puppetdb-terminus':
    ensure => present,
    notify => Class['puppet::server'],
  }
}
