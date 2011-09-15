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
#    dbadapter  => "mysql",
#    dbuser     => "puppet",
#    dbpassword => "password"
#    dbsocket   => "/var/run/mysqld/mysqld.sock",
#    reporturl  => "http://dashboard.puppetlabs.com/reports";
#  }
#
class puppet::server (
    $backup       = true,
    $modulepath   = "/etc/puppet/modules",
    $storeconfigs = 'true',
    $dbadapter    = 'sqlite3',
    $dbuser       = 'puppet',
    $dbpassword   = 'password',
    $dbserver     = 'localhost',
    $dbsocket     = '/var/run/mysqld/mysqld.sock',
    $certname     = "$fqdn",
    $reporturl    = "http://$fqdn/reports",
    $servertype   = "passenger"
  ){

  file { "/etc/puppet/manifests/site.pp":
    #content => 'node default { include puppetlabs::base }'
    content => 'import "/etc/puppet/environments/$environment/nodes/*.pp"'
  }

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

  if $storeconfigs == 'true' {
    #include puppet::storedconfiguration
    class { "puppet::storeconfig":
      dbadapter  => $dbadapter,
      dbuser     => $dbuser,
      dbpassword => $dbpassword,
      dbserver   => $dbserver,
      dbsocket   => $dbsocket
    }
  }

  if $backup == true { include puppet::server::backup }

  if $kernel != "Darwin" {
    package { $puppet::params::puppetmaster_package:
      ensure => present,
    }
  }

  concat::fragment { 'puppet.conf-header':
    order   => '05',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master.erb");
  }

  if $kernel == "Linux" { # added to support osx
    service {'puppetmaster':
      ensure    => stopped,
      enable    => false,
      hasstatus => false, # this is broken on debian if its disabled, since 0 is still returned when not running
      require   => File['/etc/puppet/puppet.conf'];
    }
  }

}

