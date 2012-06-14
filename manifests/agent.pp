class puppet::agent(
  $method = 'cron',
  $server        = hiera("puppet_server"),
  $ca_server     = hiera("puppet_ca_server", hiera("puppet_server")),
  $report_server = hiera("puppet_report_server", hiera("puppet_server")),
  $manage_agent  = false
) {

  # This could be
  #
  #    require 'puppet::package'
  #
  # yep.
  include puppet::package
  Class['puppet::package'] -> Class['puppet::agent']

  case $method {
    cron:    { include puppet::agent::cron }
    service: { include puppet::agent::service }
    default: { fail("Method ${method} is not supported by ${module}") }
  }

  # FIXME this seems silly
  # These are renamed for the template
  $puppet_server        = $server
  $puppet_ca_server     = $ca_server
  $puppet_report_server = $report_server

  # ----
  # puppet.conf management
  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/common.erb");
  }

}
