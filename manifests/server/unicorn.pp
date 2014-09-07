class puppet::server::unicorn {

  include puppet::params
  include puppet::server::rack
  class { 'nginx': }

  class { 'puppet::server::standalone':
    enabled => false,
    before  => [
      Nginx::Resource::Vhost['puppetmaster'],
      Unicorn::App['puppetmaster'],
    ],
  }

  $servername     = pick($::puppet::server::servername, $::clientcert, $::fqdn)
  $unicorn_socket = "unix:${puppet::params::puppet_rundir}/puppetmaster_unicorn.sock"

  nginx::resource::vhost { 'puppetmaster':
    server_name           => [$servername],
    ssl                   => true,
    ssl_port              => '8140',
    listen_port           => '8140', # force ssl_only by matching ssl_port
    ssl_cert              => "${::puppet::ssldir}/certs/${servername}.pem",
    ssl_key               => "${::puppet::ssldir}/private_keys/${servername}.pem",
    ssl_ciphers           => $::puppet::server::ssl_ciphers,
    ssl_protocols         => $::puppet::server::ssl_protocols,
    proxy_read_timeout    => '300',
    proxy                 => "http://puppetmaster_unicorn",
    vhost_cfg_append      => {
      ssl_crl                => "${::puppet::ssldir}/crl.pem",
      ssl_client_certificate => "${::puppet::ssldir}/certs/ca.pem",
      ssl_verify_client      => 'optional',
      proxy_connect_timeout  => '300',
      proxy_set_header       => [ 'Host $host', 'X-Real-IP $remote_addr', 'X-Forwarded-For $proxy_add_x_forwarded_for', 'X-Client-Verify $ssl_client_verify', 'X-Client-DN $ssl_client_s_dn', 'X-SSL-Issuer $ssl_client_i_dn'],
      root                   => '/usr/share/empty',
    }
  }

  nginx::resource::upstream { 'puppetmaster_unicorn':
    members => [
      $unicorn_socket
    ],
  }

  unicorn::app { 'puppetmaster':
    approot     => $::puppet::params::puppet_confdir,
    config_file => "${::puppet::params::puppet_confdir}/unicorn.conf",
    pidfile     => "${::puppet::params::puppet_rundir}/puppetmaster_unicorn.pid",
    socket      => $unicorn_socket,
    logdir      => $::puppet::params::puppet_logdir,
    user        => 'puppet',
    group       => 'puppet',
    before      => Service['nginx'],
#    export_home => $::confdir, # uncomment pending https://github.com/puppetlabs-operations/puppet-unicorn/pull/14
  }
}
