# == Class: puppet::params
#
# Provides a central point to pull hiera data.
#
class puppet::params(
  $puppet_cmd         = $puppet::params::defaults::puppet_cmd,
  $agent_package      = $puppet::params::defaults::agent_package,
  $agent_service      = $puppet::params::defaults::agent_service,
  $agent_defaults     = $puppet::params::defaults::agent_defaults,
  $agent_use          = $puppet::params::defaults::agent_use,
  $master_package     = $puppet::params::defaults::master_package,
  $master_service     = $puppet::params::defaults::master_service,
  $master_use         = $puppet::params::defaults::master_use,
  $puppet_conf        = $puppet::params::defaults::puppet_conf,
  $puppet_confdir     = $puppet::params::defaults::puppet_confdir,
  $puppet_logdir      = $puppet::params::defaults::puppet_logdir,
  $puppet_vardir      = $puppet::params::defaults::puppet_vardir,
  $puppet_ssldir      = $puppet::params::defaults::puppet_ssldir,
  $puppet_rundir      = $puppet::params::defaults::puppet_rundir,
  $unicorn_initscript = $puppet::params::defaults::unicorn_initscript,
) inherits puppet::params::defaults {

}
