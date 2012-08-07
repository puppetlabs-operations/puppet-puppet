# Use hiera to do lookups for this module data. See data.pp for defaults.
class puppet::params {

  $puppet_cmd         = hiera('puppet_cmd', undef)
  $agent_service      = hiera('agent_service', undef)
  $agent_defaults     = hiera('agent_defaults', undef)
  $master_package     = hiera('master_package', undef)
  $master_service     = hiera('master_service', undef)
  $puppet_conf        = hiera('puppet_conf', undef)
  $puppet_confdir     = hiera('puppet_confdir', undef)
  $puppet_logdir      = hiera('puppet_logdir', undef)
  $puppet_vardir      = hiera('puppet_vardir', undef)
  $puppet_ssldir      = hiera('puppet_ssldir', undef)
  $puppet_rundir      = hiera('puppet_rundir', undef)
  $unicorn_initscript = hiera('unicorn_initscript', undef)
}
