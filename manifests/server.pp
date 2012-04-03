# Class: puppet::server
#
# This class installs and configures a Puppet master
#
# Parameters:
# * modulepath
# * storeconfigs
# * dbadapter
# * dbuser
# * dbpassword
# * dbserver
# * dbsocket
# * certname
# * servertype
#
# Actions:
#
# Requires:
#
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
    $backup             = true,
    $modulepath         = '$confdir/modules/site:$confdir/env/$environment/dist',
    $manifest           = '$confdir/modules/site/site.pp',
    $config_version_cmd = '/usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo',
    $storeconfigs       = '',
    $dbadapter          = 'sqlite3',
    $dbuser             = 'puppet',
    $dbpassword         = 'password',
    $dbserver           = 'localhost',
    $dbsocket           = '/var/run/mysqld/mysqld.sock',
    $certname           = "$fqdn",
    $report             = 'true',
    $reports            = ["store", "https"],
    $reporturl          = "http://$fqdn/reports",
    $servertype         = "unicorn"
  ) {

  include puppet::params

  # ---
  # The site.pp is set in the puppet.conf, remove site.pp here to avoid confusion
  file { "${puppet::params::puppet_confdir}/manifests/site.pp": ensure => absent; }

  # ---
  # Application-server specific SSL configuration
  case $servertype {
    "passenger": {
      include puppet::server::passenger
      $ssl_client_header        = "SSL_CLIENT_S_DN"
      $ssl_client_verify_header = "SSL_CLIENT_VERIFY"
    }
    "unicorn": {
      include puppet::server::unicorn
      $ssl_client_header        = "HTTP_X_CLIENT_DN"
      $ssl_client_verify_header = "HTTP_X_CLIENT_VERIFY"
    }
    default: {
      err("Only \"passenger\" and \"unicorn\" are valid options for servertype")
      fail("Servertype \"$servertype\" not implemented")
    }
  }

  # ---
  # Storeconfigs
  case $storeconfigs {
    "mysql","postgresql","sqlite","grayskull": {
      class { "puppet::storeconfig":
        backend    => $storeconfigs,
        dbuser     => $dbuser,
        dbpassword => $dbpassword,
        dbserver   => $dbserver,
        dbsocket   => $dbsocket
      }
    }
  }

  # ---
  # Backups
  if $backup == true { include puppet::server::backup }

  # ---
  # Used only for platforms that seperate the master and agent packages
  if $puppet::params::master_package != '' {
    package { $puppet::params::master_package: ensure => present; }
  }

  if $puppet::params::master_service != '' {
    service { $puppet::params::master_service:
      ensure    => stopped,
      enable    => false,
      hasstatus => false,
      require   => File[$puppet::params::puppet_conf];
    }
  }

  # ---
  # Write the server configuration items
  concat::fragment { 'puppet.conf-master':
    order   => '05',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf-master.erb");
  }


}

