class puppet::server::unicorn {

  include puppet::params
  include puppet::server::rack
  include nginx::server

  class { 'puppet::server::standalone':
    enabled => false,
    before  => [
      Nginx::Vhost['puppetmaster'],
      Unicorn::App['puppetmaster'],
    ],
  }

  nginx::vhost { "puppetmaster":
    port     => 8140,
    template => "puppet/vhost/nginx/unicorn.conf.erb",
  }

  unicorn::app { "puppetmaster":
    approot         => $::puppet::params::puppet_confdir,
    config_file     => "${::puppet::params::puppet_confdir}/unicorn.conf",
    pidfile         => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.pid",
    socket          => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.sock",
    logdir          => $puppet::params::puppet_logdir,
    user            => 'puppet',
    group           => 'puppet',
    before          => Service['nginx'],
    subscribe       => Concat["${::puppet::params::puppet_confdir}/config.ru"],
  }
}
