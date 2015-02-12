class puppet::config (
  $logdir          = $puppet::logdir,
  $vardir          = $puppet::vardir,
  $ssldir          = $puppet::ssldir,
  $rundir          = $puppet::rundir,
  $confdir         = $puppet::confdir,
  $user            = $puppet::user,
  $group           = $puppet::group,
  $conf            = $puppet::conf,
  $use_srv_records = false,
  $srv_domain      = $::domain,
) inherits puppet {
  include puppet::params

  validate_bool($use_srv_records)

  Ini_setting {
    path    => $conf,
    ensure  => 'present',
    section => 'main',
  }

  ini_setting { 'logdir':
    setting => 'logdir',
    value   => $logdir,
  }

  ini_setting { 'vardir':
    setting => 'vardir',
    value   => $vardir,
  }

  ini_setting { 'ssldir':
    setting => 'ssldir',
    value   => $ssldir,
  }

  ini_setting { 'rundir':
    setting => 'rundir',
    value   => $rundir,
  }

  $srv_ensure = $use_srv_records ? {
    true  => 'present',
    false => 'absent',
  }

  ini_setting { 'use_srv_records':
    ensure  => $srv_ensure,
    setting => 'use_srv_records',
    value   => $use_srv_records,
  }

  ini_setting { 'srv_domain':
    ensure  => $srv_ensure,
    setting => 'srv_domain',
    value   => $srv_domain,
  }
}
