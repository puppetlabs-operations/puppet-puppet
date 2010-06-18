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

  $puppet_server = $puppet::params::puppet_server
  $puppet_storedconfig_password = $puppet::params::puppet_storedconfig_password

  package { 'puppet':
    ensure => installed,
  }

  file { $puppet::params::puppetd_defaults:
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => "puppet:///modules/puppet$puppet::params::puppetd_defaults",
  }
  service { $puppet::params::puppetd_service:
    ensure => running,
    enable => true,
    hasstatus => true,
  }

  file { '/etc/puppet/puppet.conf':
    content => $fqdn ? {
      $puppet_server => template('puppet/puppet-server.conf.erb'),
      default => template('puppet/puppet.conf.erb'),
    },
    notify => Service[$puppet::params::puppetd_service],
    require => Package['puppet'],
  }

}
