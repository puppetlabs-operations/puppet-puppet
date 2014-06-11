# == Class: puppet::server
#
# This class installs and configures a Puppet master
#
# == Description
#
# This class implements a Puppet master based around the dynamic environments
# workflow descripted in http://puppetlabs.com/blog/git-workflow-and-puppet-environments/
#
# ==  Parameters
#
# * modulepath
# * storeconfigs
# * servertype
#
# == Example
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::server":
#    modulepath => inline_template("<%= modulepath.join(':') %>"),
#    reporturl  => "https://dashboard.puppetlabs.com/reports";
#  }
#
class puppet::server (
  $modulepath         = ['$confdir/modules/site', '$confdir/env/$environment/dist'],
  $manifest           = '$confdir/modules/site/site.pp',
  $environmentpath    = undef,
  $config_version_cmd = '/usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo',
  $storeconfigs       = undef,
  $report             = true,
  $reports            = ['store', 'https'],
  $reporturl          = "http://${::fqdn}/reports",
  $reportfrom         = undef,
  $servertype         = 'unicorn',
  $serverssl_protos   = undef,
  $serverssl_ciphers  = undef,
  $ca                 = false,
  $bindaddress        = '::',
  $enc                = '',
  $enc_exec           = '',
  $servername         = undef,
  $ensure             = 'present',
  $parser             = undef,
  $gentoo_use         = $puppet::params::master_use,
  $gentoo_keywords    = $puppet::params::master_keywords,
  $manage_package     = true,
) inherits puppet::params {

  $master = true

  include puppet
  include puppet::server::config
  if $manage_package {
    include puppet::package
  }

  # ---
  # The site.pp is set in the puppet.conf, remove site.pp here to avoid confusion.
  # Unless the manifest that was passed in is the default site.pp.
  if ($manifest != "${puppet::params::puppet_confdir}/manifests/site.pp") {
    file { "${puppet::params::puppet_confdir}/manifests/site.pp": ensure => absent; }
  }

  # ---
  # Application-server specific SSL configuration
  case $servertype {
    'passenger': {
      include puppet::server::passenger
      $ssl_client_header        = 'SSL_CLIENT_S_DN'
      $ssl_client_verify_header = 'SSL_CLIENT_VERIFY'
      $ssl_protocols            = pick($serverssl_protos, '-ALL +TLSv1.2 +TLSv1.1 +TLSv1 +SSLv3')
      $ssl_ciphers              = pick($serverssl_ciphers, 'ALL:!ADH:!EXP:!LOW:+RC4:+HIGH:+MEDIUM:!SSLv2:+SSLv3:+TLSv1:+eNULL')
    }
    'unicorn': {
      include puppet::server::unicorn
      $ssl_client_header        = 'HTTP_X_CLIENT_DN'
      $ssl_client_verify_header = 'HTTP_X_CLIENT_VERIFY'
      $ssl_protocols            = pick($serverssl_protos, 'TLSv1.2 TLSv1.1 TLSv1 SSLv3')
      $ssl_ciphers              = pick($serverssl_ciphers, 'HIGH:!aNULL:!MD5')
    }
    'thin': {
      include puppet::server::thin
      $ssl_client_header        = 'HTTP_X_CLIENT_DN'
      $ssl_client_verify_header = 'HTTP_X_CLIENT_VERIFY'
      $ssl_protocols            = pick($serverssl_protos, 'TLSv1.2 TLSv1.1 TLSv1 SSLv3')
      $ssl_ciphers              = pick($serverssl_ciphers, 'HIGH:!aNULL:!MD5')
    }
    'standalone': {
      include puppet::server::standalone
    }
    default: {
      err('Only "passenger", "thin", and "unicorn" are valid options for servertype')
      fail('Servertype "$servertype" not implemented')
    }
  }

  # ---
  # Storeconfigs
  if $storeconfigs {
    class { 'puppet::storeconfig':
      backend => $storeconfigs,
    }
  }

}
