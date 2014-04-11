class puppet::server::unicorn {

  include puppet::params
  include puppet::server::rack
  include nginx::server

  class { 'puppet::server::standalone':
    enabled => false,
    before  => [
      Nginx::Unicorn['puppetmaster'],
      Unicorn::App['puppetmaster'],
    ],
  }

  $servername     = pick($::puppet::server::servername, $::clientcert, $::fqdn)
  $unicorn_socket = "${puppet::params::puppet_rundir}/puppetmaster_unicorn.sock"

  nginx::unicorn { "puppetmaster":
    servername        => $servername,
    path              => $::puppet::params::puppet_confdir,
    unicorn_socket    => $unicorn_socket,
    ssl               => true,
    sslonly           => true,
    ssl_port          => '8140',
    ssl_cert          => "${::puppet::ssldir}/certs/${servername}.pem",
    ssl_key           => "${::puppet::ssldir}/private_keys/${servername}.pem",
    ssl_ca            => "${::puppet::ssldir}/certs/ca.pem",
    ssl_crl_path      => "${::puppet::ssldir}/crl.pem",
    ssl_ciphers       => $::puppet::server::ssl_ciphers,
    ssl_protocols     => $::puppet::server::ssl_protocols,
    ssl_verify_client => "optional",
    magic             => "proxy_connect_timeout 300s;\n  proxy_read_timeout 300s;",
  }

  unicorn::app { "puppetmaster":
    approot         => $::puppet::params::puppet_confdir,
    config_file     => "${::puppet::params::puppet_confdir}/unicorn.conf",
    pidfile         => "${::puppet::params::puppet_rundir}/puppetmaster_unicorn.pid",
    socket          => $unicorn_socket,
    logdir          => $::puppet::params::puppet_logdir,
    user            => 'puppet',
    group           => 'puppet',
    before          => Service['nginx'],
    subscribe       => Concat["${::puppet::params::puppet_confdir}/config.ru"],
  }
}
