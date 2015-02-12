class puppet::agent::config {

  Ini_setting {
    path    => $puppet::conf,
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

  ini_setting { 'pluginsync':
    section => 'agent',
    setting => 'pluginsync',
    value   => $puppet::agent::pluginsync,
  }

  ini_setting { 'certname':
    section => 'agent',
    setting => 'certname',
    value   => $puppet::agent::certname,
  }

  ini_setting { 'report':
    section => 'agent',
    setting => 'report',
    value   => $puppet::agent::report,
  }

  ini_setting { 'environment':
    section => 'agent',
    setting => 'environment',
    value   => $puppet::agent::environment,
  }

  ini_setting { 'show_diff':
    section => 'agent',
    setting => 'show_diff',
    value   => $puppet::agent::showdiff,
  }

  ini_setting { 'splay':
    section => 'agent',
    setting => 'splay',
    value   => $puppet::agent::splay,
  }

  ini_setting { 'configtimeout':
    section => 'agent',
    setting => 'configtimeout',
    value   => $puppet::agent::configtimeout,
  }

  ini_setting { 'usecacheonfailure':
    section => 'agent',
    setting => 'usecacheonfailure',
    value   => $puppet::agent::usecacheonfailure,
  }

  ini_setting { 'stringify_facts_agent':
    setting => 'stringify_facts',
    section => 'agent',
    value   => $puppet::agent::stringify_facts;
  }
}
