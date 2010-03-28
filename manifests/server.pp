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
  include puppet::passenger
  if $puppet::params::storedconfiguration == 'true' {
    include puppet::storedconfiguration
  }

  package { $puppet::params::puppetmaster_package:
    ensure => present,
  }
  file { '/etc/puppet/namespaceauth.conf':
    owner => root,
    group => root,
    mode => 644,
    source => 'puppet:///modules/puppet/namespaceauth.conf',
  }
  
  service {'puppetmaster': 
    ensure => stopped, 
    enable => false, 
    hasstatus => true,
    require => File['/etc/puppet/puppet.conf'],
    before => Service['httpd'] 
  }
}
