class puppet (
    $server        = hiera("puppet_server"),
    $ca_server     = hiera("puppet_ca_server", hiera("puppet_server")),
    $report_server = hiera("puppet_report_server", hiera("puppet_server")),
    $manage_agent  = false
) {
  include puppet::params
  include concat::setup

  include puppet::agent

  # FIXME this seems silly
  $puppet_server        = $server
  $puppet_ca_server     = $ca_server
  $puppet_report_server = $report_server

  # REFACTOR use scope.lookupvar in templates instead of copying variables
  $agent_service    = $puppet::params::agent_service
  $puppet_conf      = $puppet::params::puppet_conf
  $puppet_cmd       = $puppet::params::puppet_cmd

  concat { $puppet::params::puppet_conf:
    mode => '0644',
    gnu  => $kernel ? {
      'SunOS' => 'false',
      default => 'true',
    }
  }

}

