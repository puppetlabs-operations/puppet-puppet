# Use hiera to do lookups for this module data. See data.pp for defaults.
class puppet::params {

  include puppet::params::defaults

  $puppet_cmd         = hiera('puppet_cmd',         $puppet::params::defaults::puppet_cmd)
  $agent_service      = hiera('agent_service',      $puppet::params::defaults::agent_service)
  $agent_defaults     = hiera('agent_defaults',     $puppet::params::defaults::agent_defaults)
  $update_puppet      = hiera('update_puppet',      $puppet::params::defaults::update_puppet)
  $master_package     = hiera('master_package',     $puppet::params::defaults::master_package)
  $master_service     = hiera('master_service',     $puppet::params::defaults::master_service)
  $puppet_conf        = hiera('puppet_conf',        $puppet::params::defaults::puppet_conf)
  $puppet_confdir     = hiera('puppet_confdir',     $puppet::params::defaults::puppet_confdir)
  $puppet_logdir      = hiera('puppet_logdir',      $puppet::params::defaults::puppet_logdir)
  $puppet_vardir      = hiera('puppet_vardir',      $puppet::params::defaults::puppet_vardir)
  $puppet_ssldir      = hiera('puppet_ssldir',      $puppet::params::defaults::puppet_ssldir)
  $puppet_rundir      = hiera('puppet_rundir',      $puppet::params::defaults::puppet_rundir)
  $unicorn_initscript = hiera('unicorn_initscript', $puppet::params::defaults::unicorn_initscript)
}
