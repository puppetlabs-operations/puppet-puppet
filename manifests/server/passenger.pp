class puppet::server::passenger {
  class { 'puppet::server::standalone': enabled => false }

  if $::kernel == 'Darwin' {
    fail('puppet::server::passenger not supported on OS X')
  }

  include apache
  include apache::mod::ssl
  include apache::mod::passenger

  file { ['/etc/puppet/rack', '/etc/puppet/rack/public/', '/etc/puppet/rack/tmp']:
      ensure => directory,
      owner  => 'puppet',
      group  => 'puppet',
  }

  $source   = $::puppetversion ? {
    /^2.7/ => 'puppet:///modules/puppet/config.ru.passenger.27',
    /^3./  => 'puppet:///modules/puppet/config.ru.passenger.3',
  }

  file { '/etc/puppet/rack/config.ru':
    owner    => 'puppet',
    group    => 'puppet',
    mode     => '0644',
    source   => $source,
  }

  if $puppet::server::bindaddress == '::' {
    $ip = '*'
  } else {
    $ip = $puppet::server::bindaddress
  }

  apache::vhost { 'puppetmaster':
    servername        => $puppet::server::servername,
    ip                => $ip,
    port              => '8140',
    priority          => '10',
    docroot           => '/etc/puppet/rack/public/',
    ssl               => true,
    ssl_cipher        => $puppet::server::ssl_ciphers,
    ssl_protocol      => $puppet::server::ssl_protocols,
    ssl_cert          => "${puppet::ssldir}/certs/${puppet::server::servername}.pem",
    ssl_key           => "${puppet::ssldir}/private_keys/${puppet::server::servername}.pem",
    ssl_chain         => "${puppet::ssldir}/certs/ca.pem",
    ssl_ca            => "${puppet::ssldir}/ca/ca_crt.pem",
    ssl_crl           => "${puppet::ssldir}/ca/ca_crl.pem",
    ssl_verify_client => 'optional',
    ssl_verify_depth  => '1',
    ssl_options       => ['+StdEnvVars', '+ExportCertData'],
    request_headers   => [
      'set X-SSL-Subject %{SSL_CLIENT_S_DN}e',
      'set X-Client-DN %{SSL_CLIENT_S_DN}e',
      'set X-Client-Verify %{SSL_CLIENT_VERIFY}e',
    ],
  }
}
