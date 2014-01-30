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
# [*monitor_service*]
#   Whether or not to monitor the puppet service.
#   Should not be mixed when method is cron.
#   Default: false
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
class puppet::agent(
  $ensure            = 'present',
  $server            = 'puppet',
  $ca_server         = undef,
  $report            = true,
  $report_server     = undef,
  $report_format     = undef,
  $manage_repos      = true,
  $monitor_service   = false,
  $environment       = $::environment,
  $pluginsync        = true,
  $certname          = $::clientcert,
  $showdiff          = true,
  $splay             = false,
  $configtimeout     = 360,
  $usecacheonfailure = true,
  $method            = $puppet::params::default_method,
  $gentoo_use        = $puppet::params::agent_use,
  $gentoo_keywords   = $puppet::params::agent_keywords,
  $manage_package    = true,
) inherits puppet::params {

  include puppet
  if $manage_package {
    include puppet::package
  }

  if $report_server {
    $real_report_server = $report_server
  } else {
    $real_report_server = $server
  }

  if $ca_server {
    $real_ca_server = $ca_server
  } else {
    $real_ca_server = $server
  }

  include puppet::agent::config

  class { '::puppet::agent::monitor': enable => $monitor_service }

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
