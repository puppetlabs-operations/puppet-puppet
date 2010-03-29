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
  }
}
