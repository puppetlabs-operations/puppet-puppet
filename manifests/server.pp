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
    $reporturl    = "http://$fqdn/reports"

  ){

  #include puppet
  include puppet::passenger

  if $storeconfigs == 'true' {
    #include puppet::storedconfiguration
    class { "puppet::storeconfig":
      dbadapter  => $dbadapter,
      dbuser     => $dbuser,
      dbpassword => $dbpassword,
      dbserver   => $dbserver,
      dbsocket   => $socket
    }
  }

  if $backup == true { include puppet::server::backup }

  package { $puppet::params::puppetmaster_package:
    ensure => present,
  }

  file { '/etc/puppet/namespaceauth.conf':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/puppet/namespaceauth.conf';
  }

  concat::fragment { 'puppet.conf-header':
    order   => '05',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master.erb");
  }

  service {'puppetmaster':
    ensure    => stopped,
    enable    => false,
    hasstatus => true,
    require   => File['/etc/puppet/puppet.conf'],
    before    => Service['httpd'];
  }

}

