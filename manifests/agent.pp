# == Class: puppet::agent
#
# Install, configure, and run a puppet agent instance.
#
# == Parameters
#
# [*ensure*]
# The package ensure value.
# Default: present
#
# [*server*]
# The puppet server to use for fetching catalogs.
# Default: puppet
#
# [*ca_server*]
# The puppet server to use for certificate requests and similar actions.
# Default: puppet::agent::server
#
# [*report*]
# The report variable in puppet.conf, whether to send reports or not
# Default: true
#
# [*report_server*]
# The puppet server to send reports.
# Default: puppet::agent::server
#
# [*manage_repos*]
# Whether to manage Puppet Labs APT or YUM package repos.
# Default: false
#
# [*environment*]
# What environment the agent should be part of.
# Default: $::environment
#
# [*pluginsync*]
# The pluginsync variable in puppet.conf
# Default: true
#
# [*certname*]
# The certname variable in puppet.conf
# Default: $::clientcert
#
# [*show_diff*]
# The show_diff variable in puppet.conf
# Default: false
#
# [*splay*]
# The splay variable in puppet.conf
# Default: false
#
# [*configtimeout*]
# The configtimeout variable in puppet.conf
# Default: 360
#
# [*usecacheonfailure*]
# The usecacheonfailure variable in puppet.conf
# Default: true
#
# [*method*]
# The mechanism for performing puppet runs.
# Supported methods: [cron, service, only_service, none]
# Default: platform dependent
#
# [*manage_package*]
# Whether to manage the puppet agent package or not
# Default: true
#
# [*package*]
# The puppet agent package name
# Default: platform dependent
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
  $manage_repos      = false,
  $environment       = $::environment,
  $pluginsync        = true,
  $certname          = $::clientcert,
  $show_diff         = false,
  $splay             = false,
  $configtimeout     = 360,
  $usecacheonfailure = true,
  $method            = $puppet::params::default_method,
  $manage_package    = true,
  $package           = $puppet::params::agent_package,
) inherits puppet::params {

  validate_bool($report)
  validate_bool($manage_repos)
  validate_bool($pluginsync)
  validate_bool($show_diff)
  validate_bool($splay)
  validate_bool($usecacheonfailure)
  validate_bool($manage_package)

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
