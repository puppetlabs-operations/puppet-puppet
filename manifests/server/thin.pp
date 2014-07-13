class puppet::server::thin {

  include puppet::params
  include puppet::server::rack

  class { 'puppet::server::standalone':
    enabled => false,
    before  => Class['nginx'],
  }
  class { '::thin': }
  class { 'nginx': }

  Ini_setting {
    ensure  => 'present',
    section => 'master',
    path    => $puppet::params::puppet_conf,
  }

  ini_setting {
    'ssl_client_header':
      ensure  => 'absent',
      setting => 'ssl_client_header';
    'ssl_client_verify_header':
      ensure  => 'absent',
      setting => 'ssl_client_verify_header';
  }

  $servers     = $::processorcount
  $servername  = pick($::puppet::server::servername, $::clientcert, $::fqdn)
  $thin_socket = "unix:${puppet::params::puppet_rundir}/puppetmaster.0.sock"

  nginx::resource::vhost { 'puppetmaster':
    server_name        => [$servername],
    ssl                => true,
    ssl_port           => '8140',
    listen_port        => '8140', # force ssl_only by matching ssl_port
    ssl_cert           => "${::puppet::ssldir}/certs/${servername}.pem",
    ssl_key            => "${::puppet::ssldir}/private_keys/${servername}.pem",
    ssl_ciphers        => $::puppet::server::ssl_ciphers,
    ssl_protocols      => $::puppet::server::ssl_protocols,
    proxy_read_timeout => '300',
    proxy              => 'http://puppetmaster_thin',
    vhost_cfg_append   => {
      ssl_crl                => "${::puppet::ssldir}/crl.pem",
      ssl_client_certificate => "${::puppet::ssldir}/certs/ca.pem",
      ssl_verify_client      => 'optional',
      proxy_connect_timeout  => '300',
      proxy_set_header       => [ 'Host $host',
                                'X-Real-IP $remote_addr',
                                'X-Forwarded-For $proxy_add_x_forwarded_for',
                                'X-Client-Verify $ssl_client_verify',
                                'X-Client-DN $ssl_client_s_dn',
                                'X-SSL-Issuer $ssl_client_i_dn'],
      root                   => '/usr/share/empty',
    }
  }

  nginx::resource::upstream { 'puppetmaster_thin':
    members => [
      $thin_socket
    ],
  }

  concat::fragment { 'proctitle':
    order  => '05',
    target => "${::puppet::params::puppet_confdir}/config.ru",
    source => 'puppet:///modules/puppet/config.ru/05-proctitle.rb',
  }

  thin::app { 'puppetmaster':
    user       => 'puppet',
    group      => 'puppet',
    rackup     => "${::puppet::params::puppet_confdir}/config.ru",
    chdir      => $puppet::params::puppet_confdir,
    subscribe  => Concat["${::puppet::params::puppet_confdir}/config.ru"],
    require    => Class['::thin'],
    socket     => "${puppet::params::puppet_rundir}/puppetmaster.sock",
    force_home => '/etc/puppet',
  }
}
