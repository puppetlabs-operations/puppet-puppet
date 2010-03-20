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
  service{ $puppet::params::puppetd_service:
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
}
