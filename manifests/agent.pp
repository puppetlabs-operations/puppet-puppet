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
# [*manage_service*]
#   Whether to manage the puppet agent service when using the cron run method.
#   Default: undef
# [*method*]
#   The mechanism for performing puppet runs.
#   Supported methods: [cron, service]
#   Default: cron
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
  $server         = hiera('puppet::agent::server', 'puppet'),
  $ca_server      = hiera('puppet::agent::server', 'puppet'),
  $report_server  = hiera('puppet::agent::server', 'puppet'),
  $manage_repos   = true,
  $manage_service = undef,
  $method         = 'cron',
  $environment    = 'production'
) {

  include puppet

  if $manage_repos {
    require puppet::package
  }

  case $method {
    cron:    { class { 'puppet::agent::cron': manage_service => $manage_service } }
    service: { include puppet::agent::service }
    default: {
      notify { "Agent run method \"${method}\" is not supported by ${module_name}, defaulting to cron": loglevel => warning }
      class { 'puppet::agent::cron': manage_service => $manage_service }
    }
  }

  # ----
  # puppet.conf management
  concat::fragment { 'puppet.conf-agent':
    order   => '00',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/agent.erb");
  }

}
