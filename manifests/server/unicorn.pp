class puppet::server::unicorn {

  class { 'puppet::server::standalone':
    enabled => false,
    before  => [
      Nginx::Vhost['puppetmaster'],
      Unicorn::App['puppetmaster'],
    ],
  }

  include puppet::params
  include nginx::server
  nginx::vhost { "puppetmaster":
    port     => 8140,
    template => "puppet/vhost/nginx/unicorn.conf.erb",
  }

  unicorn::app { "puppetmaster":
    approot         => $::puppet::params::puppet_confdir,
    config_file     => "${::puppet::params::puppet_confdir}/unicorn.conf",
    initscript      => $puppet::params::unicorn_initscript,
    unicorn_pidfile => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.pid",
    unicorn_socket  => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.sock",
    stdlog_path     => $puppet::params::puppet_logdir,
    log_stds        => 'true',
    unicorn_user    => 'puppet',
    unicorn_group   => 'puppet',
    before          => Service['nginx'],
  }
}
