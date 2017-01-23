# Private class
class puppet::server::unicorn {

  include puppet
  include puppet::server::rack
  include nginx

  class { 'puppet::server::standalone':
    enabled => false,
    before  => [
      Nginx::Resource::Server['puppetmaster'],
      Unicorn::App['puppetmaster'],
    ],
  }

  $unicorn_socket = "unix:${puppet::rundir}/puppetmaster_unicorn.sock"

  nginx::resource::server { 'puppetmaster':
    server_name          => [$puppet::server::servername],
    listen_ip            => $puppet::server::bindaddress,
    ssl                  => true,
    ssl_port             => '8140',
    listen_port          => '8140', # force ssl_only by matching ssl_port
    ssl_cert             => "${puppet::ssldir}/certs/${puppet::server::servername}.pem",
    ssl_key              => "${puppet::ssldir}/private_keys/${puppet::server::servername}.pem",
    ssl_ciphers          => $puppet::server::ssl_ciphers,
    ssl_protocols        => $puppet::server::ssl_protocols,
    ssl_crl              => "${puppet::ssldir}/crl.pem",
    ssl_client_cert      => "${puppet::ssldir}/certs/ca.pem",
    ssl_verify_client    => 'optional',
    use_default_location => false,
    www_root             => '/usr/share/empty',
  }
  nginx::resource::location { 'unicorn_upstream':
    ensure                => present,
    location              => '/',
    server                => 'puppetmaster',
    proxy                 => 'http://puppetmaster_unicorn',
    proxy_redirect        => 'off',
    proxy_connect_timeout => '90',
    proxy_read_timeout    => '300',
    proxy_set_header      => ['Host $host',
                              'X-Real-IP $remote_addr',
                              'X-Forwarded-For $proxy_add_x_forwarded_for',
                              'X-Client-Verify $ssl_client_verify',
                              'X-Client-DN $ssl_client_s_dn',
                              'X-SSL-Issuer $ssl_client_i_dn'],
    ssl_only              => true,
  }
  nginx::resource::upstream { 'puppetmaster_unicorn':
    members => [
      $unicorn_socket
    ],
  }

  if ! empty( $::puppet::server::external_ca )
  {
    nginx::resource::location { 'external_certificate_authority_proxy':
      ensure                => present,
      location              => '~ ^/.*/certificate.*',
      server                => 'puppetmaster',
      proxy_set_header      => [],
      proxy                 => $puppet::server::external_ca,
      proxy_redirect        => 'off',
      proxy_connect_timeout => '90',
      proxy_read_timeout    => '300',
      ssl_only              => true,
    }
  }

  unicorn::app { 'puppetmaster':
    approot     => $puppet::confdir,
    config_file => "${puppet::confdir}/unicorn.conf",
    pidfile     => "${puppet::rundir}/puppetmaster_unicorn.pid",
    socket      => $unicorn_socket,
    logdir      => $puppet::logdir,
    user        => $puppet::user,
    group       => $puppet::group,
    before      => Service['nginx'],
#    export_home => $::confdir, # uncomment pending https://github.com/puppetlabs-operations/puppet-unicorn/pull/14
  }
}
