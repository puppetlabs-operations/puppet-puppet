class puppet::config {

  Ini_setting {
    path    => $puppet::conf,
    ensure  => 'present',
    section => 'main',
  }

  ini_setting { 'logdir':
    setting => 'logdir',
    value   => $puppet::logdir,
  }

  ini_setting { 'vardir':
    setting => 'vardir',
    value   => $puppet::vardir,
  }

  ini_setting { 'ssldir':
    setting => 'ssldir',
    value   => $puppet::ssldir,
  }

  ini_setting { 'rundir':
    setting => 'rundir',
    value   => $puppet::rundir,
  }

  $srv_ensure = $puppet::use_srv_records ? {
    true  => 'present',
    false => 'absent',
  }

  ini_setting { 'use_srv_records':
    ensure  => $srv_ensure,
    setting => 'use_srv_records',
    value   => $puppet::use_srv_records,
  }

  ini_setting { 'srv_domain':
    ensure  => $srv_ensure,
    setting => 'srv_domain',
    value   => $puppet::srv_domain,
  }
}
