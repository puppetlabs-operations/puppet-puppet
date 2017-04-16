class puppet::agent::config {

  file { $puppet::params::puppet_conf:
    ensure => $puppet::agent::ensure ? {
                  'present' => 'file',
                  'absent'  => 'absent',
                  default   => 'absent'
                },
    mode   => 644,
  }

  Ini_setting {
    path    => $puppet::conf,
    section => 'agent',
    ensure  => 'present',
    notify  => Service['puppet_agent'],
  }

  ini_setting { 'server':
    section => 'main',
    setting => 'server',
    value   => $puppet::agent::server,
  }

  if $puppet::agent::ca_server {
    $real_ca_server = $puppet::agent::ca_server
  } else {
    $real_ca_server = $puppet::agent::server
  }

  ini_setting { 'ca_server':
    section => 'main',
    setting => 'ca_server',
    value   => $real_ca_server,
  }

  if $puppet::agent::report_server {
    $real_report_server = $puppet::agent::report_server
  } else {
    $real_report_server = $puppet::agent::server
  }

  ini_setting { 'report_server':
    section => 'main',
    setting => 'report_server',
    value   => $real_report_server,
  }

  ini_setting { 'pluginsync':
    setting => 'pluginsync',
    value   => $puppet::agent::pluginsync,
  }

  ini_setting { 'certname':
    setting => 'certname',
    value   => $puppet::agent::certname,
  }

  ini_setting { 'report':
    setting => 'report',
    value   => $puppet::agent::report,
  }

  ini_setting { 'environment':
    setting => 'environment',
    value   => $puppet::agent::environment,
  }

  ini_setting { 'show_diff':
    setting => 'show_diff',
    value   => $puppet::agent::show_diff,
  }

  ini_setting { 'splay':
    setting => 'splay',
    value   => $puppet::agent::splay,
  }

  ini_setting { 'configtimeout':
    setting => 'configtimeout',
    value   => $puppet::agent::configtimeout,
  }

  ini_setting { 'usecacheonfailure':
    setting => 'usecacheonfailure',
    value   => $puppet::agent::usecacheonfailure,
  }

  if ! empty( $puppet::agent::runinterval )
  {
    ini_setting { 'runinterval':
      setting => 'runinterval',
      value   => $puppet::agent::runinterval,
    }
  }
}
