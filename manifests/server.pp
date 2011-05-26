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
    $modulepath = "/etc/puppet/modules",
    $storeconfigs = 'true',
    $dbadapter = 'sqlite3',
    $dbuser = '',
    $dbpassword = '',
    $dbserver = '',
    $dbsocket = '',
    $certname = $fqdn

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
    order   => '00',
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

