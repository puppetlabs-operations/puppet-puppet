class puppet::agent::config {
  include puppet::params

  Ini_setting {
    path    => $puppet::params::puppet_conf,
    ensure  => 'present',
  }

  ini_setting { 'server':
    section => 'main',
    setting => 'server',
    value   => $puppet::agent::server,
  }

  ini_setting { 'ca_server':
    section => 'main',
    setting => 'ca_server',
    value   => $puppet::agent::real_ca_server,
  }

  ini_setting { 'report_server':
    section => 'main',
    setting => 'report_server',
    value   => $puppet::agent::real_report_server,
  }

  ini_setting { 'report_format':
    section => 'main',
    setting => 'report_format',
    value   => $puppet::agent::report_format,
  }

  ini_setting { 'pluginsync':
    section => 'main',
    setting => 'pluginsync',
    value   => 'true'
  }

  ini_setting { 'logdir':
    section => 'main',
    setting => 'logdir',
    value   => $puppet::puppet_logdir,
  }

  ini_setting { 'vardir':
    section => 'main',
    setting => 'vardir',
    value   => $puppet::puppet_vardir,
  }

  ini_setting { 'ssldir':
    section => 'main',
    setting => 'ssldir',
    value   => $puppet::puppet_ssldir,
  }

  ini_setting { 'rundir':
    section => 'main',
    setting => 'rundir',
    value   => $puppet::puppet_rundir,
  }

  ini_setting { 'certname':
    section => 'agent',
    setting => 'certname',
    value   => $::clientcert,
  }

  ini_setting { 'report':
    section => 'agent',
    setting => 'report',
    value   => 'true',
  }

  ini_setting { 'environment':
    section => 'agent',
    setting => 'environment',
    value   => $puppet::agent::environment,
  }

  ini_setting { 'show_diff':
    section => 'agent',
    setting => 'show_diff',
    value   => 'true',
  }

  ini_setting { 'splay':
    section => 'agent',
    setting => 'splay',
    value   => 'false',
  }

  ini_setting { 'configtimeout':
    section => 'agent',
    setting => 'configtimeout',
    value   => '360',
  }
}
