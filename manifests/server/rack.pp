# == Class: puppet::server::rack
#
# This class creates the config.ru filr that is necessary for rack based
# application servers.
#
# Application server classes that depend on this config.ru should include this
# class.
#
class puppet::server::rack {

  # Template variables for concat fragment
  $puppet_confdir = $::puppet::params::puppet_confdir
  $puppet_vardir  = $::puppet::params::puppet_vardir

  concat { "${puppet_confdir}/config.ru":
    owner => 'puppet',
    group => 'puppet',
    mode  => '0644',
  }

  concat::fragment { 'run-puppet-master':
    order   => '99',
    target  => "${puppet_confdir}/config.ru",
    content => template('puppet/config.ru/99-run-3.0.erb'),
  }
}
