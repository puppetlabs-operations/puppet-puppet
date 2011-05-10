# Class: puppet::server
#
# This class installs and configures a Puppet master
#
# Parameters:
# * modulepath
#
# Actions:
#
# Requires:
#
# Sample Usage:
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

