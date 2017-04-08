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
# [*autosign*]
# The autosign variable in puppet.conf
# Default: undef
#
# [*bindaddress*]
# The bindaddress variable in puppet.conf
# Default: 0.0.0.0
#
# [*ca*]
# The ca variable in puppet.conf
# Default: false
#
# [*config_version*]
# The config_version variable in puppet.conf
# Default: /usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo
#
# [*dns_alt_names*]
# The dns_alt_names variable in puppet.conf
# Default: undef
#
# [*enc*]
# ??
# Default: empty string
#
# [*enc_exec*]
# ??
# Default: empty string
#
# [*ensure*]
# The ensure value for the puppet master package
# Default: present
#
# [*directoryenvs*]
# Whether we should be using directory environments
# Default: true
#
# [*environmentpath*]
# The environmentpath variable in puppet.conf
# Default: undef
#
# [*basemodulepath*]
# The basemodulepath variable in puppet.conf
# Default: empty list
#
# [*default_manifest*]
# The default_manifest variable in puppet.conf
# Default: undef
#
# [*manage_package*]
# Whether to manage the puppet master package
# Default: true
#
# [*manifest*]
# The manifest variable in puppet.conf
# Default: $confdir/modules/site/site.pp
#
# [*modulepath*]
# The modulepath variable in puppet.conf
# Default: empty list
#
# [*parser*]
# ??
# Default: undef
#
# [*manage_puppetdb*]
# Whether to manage puppetdb master config through puppetlabs/puppetdb module
# Default: false
#
# [*report_dir*]
# The report_dir variable in puppet.conf
# Default: platform dependent
#
# [*reportfrom*]
# The reportfrom variable in puppet.conf
# Default: undef
#
# [*reports*]
# The reports variable from puppet.conf
# Default: ['store', 'https']
#
# [*reporturl*]
# The reporturl variable in puppet.conf
# Default: https://${::fqdn}/reports
#
# [*servername*]
# The Puppet Master's name, used for the web servers that serve puppetmaster
# Default: $::fqdn
#
# [*serverssl_ciphers*]
# SSL ciphers to enable on the web servers that serve puppetmaster
# Default: application dependent
#
# [*serverssl_protos*]
# SSL protocols to enable on the web servers that serve puppetmaster
# Default: application dependent
#
# [*servertype*]
# The web server to choose for serving the puppetmaster
# Default: unicorn
#
# [*storeconfigs*]
# The storeconfigs backend
# Default: undef
#
# [*package*]
# The puppetmaster package name
# Default: platform dependent
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
  $autosign          = undef,
  $bindaddress       = '0.0.0.0',
  $ca                = false,
  $config_version    = '/usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo',
  $dns_alt_names     = [],
  $enc               = '',
  $enc_exec          = '',
  $ensure            = 'present',
  $directoryenvs     = true,
  $environmentpath   = '$confdir/environments',
  $basemodulepath    = [],
  $default_manifest  = undef,
  $manage_package    = true,
  $manifest          = undef,
  $modulepath        = [],
  $parser            = undef,
  $manage_puppetdb   = false,
  $report_dir        = $puppet::params::report_dir,
  $reportfrom        = undef,
  $reports           = ['store', 'https'],
  $reporturl         = "https://${::fqdn}/reports",
  $servername        = $::fqdn,
  $serverssl_ciphers = undef,
  $serverssl_protos  = undef,
  $servertype        = 'unicorn',
  $storeconfigs      = undef,
  $package           = $puppet::params::master_package,
  $tagmail           = {},
  $external_ca       = undef,
) inherits puppet::params {

  validate_bool($ca)
  validate_bool($directoryenvs)
  validate_bool($manage_puppetdb)
  if $dns_alt_names { validate_array($dns_alt_names) }
  if $reports { validate_array($reports) }
  if $parser { validate_re($parser, ['custom', 'future']) }
  if $tagmail { validate_hash($tagmail) }

  $service = $servertype ? {
    'passenger'    => 'httpd',
    'unicorn'      => 'unicorn_puppetmaster',
    'standalone'   => $puppet::params::master_service,
  }

  include puppet
  include puppet::server::config

  if $manage_package and ($puppet::agent::package != $package) {
    package { $package:
      ensure => $ensure,
      notify => Service[$service],
    }
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
    'standalone': {
      include puppet::server::standalone
    }
    default: {
      err('Only "passenger", "unicorn" and "standalone" are valid options for servertype')
      fail('Servertype "$servertype" not implemented')
    }
  }

  # ---
  # Storeconfigs
  if $storeconfigs {
    notify { 'storeconfigs is deprecated. Use manage_puppetdb setting.': }
    class { 'puppet::storeconfig':
      backend => $storeconfigs,
    }
  }

  if $manage_puppetdb {
    include puppetdb::master::config
  }

  if ! empty($tagmail) {
    file { "${puppet::confdir}/tagmail.conf":
      ensure  => file,
      owner   => $puppet::user,
      group   => $puppet::group,
      mode    => '0644',
      content => template('puppet/tagmail.conf.erb'),
    }
  }
}
