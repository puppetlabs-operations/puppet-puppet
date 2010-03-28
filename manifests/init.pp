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

  #
  # This a hack for debian because the init script checks
  # /etc/defaults/puppet for $START. Not sure how we want to approach fixing this.
  # Can't be modeled with params.  Redhat has a default directory but no puppet file.
  #
  file {'/etc/default/puppet':
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => 'puppet:///modules/puppet/etc_default_puppet',
  }
  service{ $puppet::params::puppetd_service:
    ensure => running,
    enable => true,
    hasstatus => true,
    require => [ File['/etc/default/puppet'], File['/etc/puppet/puppet.conf'] ],
  }
}
