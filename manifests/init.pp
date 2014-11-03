# == Class: puppet
#
# == Description
#
# This manifest provides for shared behavior and resources between the agent
# and master.
#
# This module should not be directly included.
#
class puppet (
  $logdir  = $puppet::params::puppet_logdir,
  $vardir  = $puppet::params::puppet_vardir,
  $ssldir  = $puppet::params::puppet_ssldir,
  $rundir  = $puppet::params::puppet_rundir,
  $confdir = $puppet::params::puppet_confdir,
) inherits puppet::params {

  file { $confdir:
    ensure => 'directory',
    owner  => 'puppet',
    group  => 'puppet',
  }
}
