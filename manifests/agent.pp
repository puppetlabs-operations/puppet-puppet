# == Class: puppet::agent
#
# Install, configure, and run a puppet agent instance.
#
# == Parameters
#
# [*server*]
#   The puppet server to use for fetching catalogs. Required.
# [*ca_server*]
#   The puppet server to use for certificate requests and similar actions.
#   Default: puppet::agent::server
# [*report_server*]
#   The puppet server to send reports.
#   Default: puppet::agent::server
# [*manage_repos*]
#   Whether to manage Puppet Labs APT or YUM package repos.
#   Default: true
# [*method*]
#   The mechanism for performing puppet runs.
#   Supported methods: [cron, service]
#   Default: cron
# [*environment*]
#   What environment the agent should be part of.
#   Default: $::environment
#
# == Example:
#
#   class { 'puppet::agent':
#     server        => 'puppet.example.com',
#     report_server => 'puppet_reports.example.com',
#     method        => 'service',
#  }
#
class puppet::agent (
  $ensure            = 'present',
  $server            = 'puppet',
  $ca_server         = undef,
  $report            = true,
  $report_server     = undef,
  $manage_repos      = true,
  $environment       = $::environment,
  $pluginsync        = true,
  $certname          = $::clientcert,
  $showdiff          = false,
  $splay             = false,
  $configtimeout     = 360,
  $usecacheonfailure = true,
  $method            = $puppet::params::default_method,
  $gentoo_use        = $puppet::params::agent_use,
  $gentoo_keywords   = $puppet::params::agent_keywords,
  $manage_package    = true,
  $stringify_facts   = false,
) inherits puppet::params {

  validate_bool($report)
  validate_bool($manage_repos)
  validate_bool($pluginsync)
  validate_bool($showdiff)
  validate_bool($splay)
  validate_bool($usecacheonfailure)
  validate_bool($manage_package)
  validate_bool($stringify_facts)

  include puppet

  if $manage_package {
    include puppet::package
  }

  if $ensure != 'absent' {
    include puppet::agent::config
  }

  case $method {
    cron: {
      include puppet::agent::cron
      class { 'puppet::agent::service': enable => false }
    }
    service: {
      include puppet::agent::service
      class { 'puppet::agent::cron': enable => false }
    }
    only_service: {
      include puppet::agent::service
    }
    none: {
      class { 'puppet::agent::service': enable => false }
      class { 'puppet::agent::cron': enable => false }
    }
    default: {
      notify { "Agent run method \"${method}\" is not supported by ${module_name}, defaulting to cron": loglevel => warning }
      include puppet::agent::cron
      class { 'puppet::agent::service': enable => false }
    }
  }
}
