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
# * dbadapter
# * dbuser
# * dbpassword
# * dbserver
# * dbsocket
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
    $modulepath         = '$confdir/modules/site:$confdir/env/$environment/dist',
    $manifest           = '$confdir/modules/site/site.pp',
    $config_version_cmd = '/usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo',
    $storeconfigs       = undef,
    $report             = 'true',
    $reports            = ["store", "https"],
    $reporturl          = "http://$fqdn/reports",
    $servertype         = "unicorn",
    $ca                 = false,
    $bindaddress        = '::',
    $enc                = '',
    $enc_exec           = '',
    $monitor_server     = hiera('puppet_server_monitor', 'true'),
    $backup_server      = hiera('puppet_server_backup', 'true')
  ) {

  include puppet
  include puppet::params
  include puppet::server::config

  # ---
  # The site.pp is set in the puppet.conf, remove site.pp here to avoid confusion.
  # Unless the manifest that was passed in is the default site.pp.
  if ($manifest != "${puppet::params::puppet_confdir}/manifests/site.pp") {
    file { "${puppet::params::puppet_confdir}/manifests/site.pp": ensure => absent; }
  }

  # ---
  # Application-server specific SSL configuration
  case $servertype {
    "passenger": {
      include puppet::server::passenger
      include puppet::server::standalone_off
      $ssl_client_header        = "SSL_CLIENT_S_DN"
      $ssl_client_verify_header = "SSL_CLIENT_VERIFY"
    }
    "unicorn": {
      include puppet::server::unicorn
      include puppet::server::standalone_off
      $ssl_client_header        = "HTTP_X_CLIENT_DN"
      $ssl_client_verify_header = "HTTP_X_CLIENT_VERIFY"
    }
    "thin": {
      include puppet::server::thin
      include puppet::server::standalone_off
      $ssl_client_header        = "HTTP_X_CLIENT_DN"
      $ssl_client_verify_header = "HTTP_X_CLIENT_VERIFY"
    }
    "standalone": {
      include puppet::server::standalone
    }
    default: {
      err('Only "passenger", "thin", and "unicorn" are valid options for servertype')
      fail("Servertype \"$servertype\" not implemented")
    }
  }

  # ---
  # Storeconfigs
  if $storeconfigs {
    class { "puppet::storeconfig":
      backend => $storeconfigs,
    }
  }

  # ---
  # Backups
  #
  # FIXME
  # http://projects.puppetlabs.com/issues/10590
  # err: Could not retrieve catalog from remote server: Error 400 on SERVER: can't clone TrueClass
  #
  # Use a real boolean after hiera 1.0 is out
  #
  if $backup_server  == 'true' { include puppet::server::backup }
  if $monitor_server == 'true' { include puppet::server::monitor }

  # ---
  # Used only for platforms that seperate the master and agent packages
  if $puppet::params::master_package != '' {
    package { $puppet::params::master_package: ensure => present; }
  }
}
