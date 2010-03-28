# Class: puppet
#
# This class installs and configures Puppet
#
# Parameters:
#
# Actions:
#   - Install Puppet
#
# Requires:
#
# Sample Usage:
#
class puppet {
  include ruby
  include puppet::params

  package{'puppet':
    ensure => installed,
  }

  file { '/etc/puppet/puppet.conf':
    ensure => present,
    content => template('puppet/puppet.conf.erb'),
  }

  file { $puppet::params::puppetd_defaults:
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => "puppet:///modules/puppet/$puppet::params::puppetd_defaults",
  }
  service{ $puppet::params::puppetd_service:
    ensure => running,
    enable => true,
    hasstatus => true,
    require => [ File[$puppet::params::puppetd_service], File['/etc/puppet/puppet.conf'] ],
  }
}
