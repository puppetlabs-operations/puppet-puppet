class puppet::server::thin {

  include puppet::params

  file { "${::puppet::params::puppet_confdir}/config.ru":
    ensure => present,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    source => 'puppet:///modules/puppet/config.ru',
    before => Thin::App['puppetmaster'],
  }

  thin::app { 'puppetmaster':
    user   => 'puppet',
    group  => 'puppet',
    rackup => "${::puppet::params::puppet_confdir}/config.ru",
  }

  motd::register {"Puppet master on Thin": }
}
