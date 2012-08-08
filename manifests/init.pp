class puppet (
    $server         = hiera("puppet_server"),
    $ca_server      = hiera("puppet_ca_server", hiera("puppet_server")),
    $report_server  = hiera("puppet_report_server", hiera("puppet_server")),
    $manage_service = false
) {
  include puppet::params
  include concat::setup

  # This is for compatibility. Agents should include puppet::agent over puppet
  class { 'puppet::agent':
    method          => $cron,
    server          => $server,
    ca_server       => $ca_server,
    report_server   => $report_server,
    manage_service  => $manage_service,
  }

  concat { $puppet::params::puppet_conf:
    mode => '0644',
    gnu  => $kernel ? {
      'SunOS' => 'false',
      default => 'true',
    }
  }

}

