# Class: puppet::server
#
# This class installs and configures a Puppet master
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::server {
  include puppet

  package { $puppet::params::puppetmaster_package:
    ensure => present,
  }
  
  service{ $puppet::params::puppemasterd_service:
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
  file{'/etc/puppet/namespaceauth.conf':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/puppet/namespaceauth.conf',
  }
}
