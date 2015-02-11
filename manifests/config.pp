class puppet::config (
  $logdir  = $puppet::logdir,
  $vardir  = $puppet::vardir,
  $ssldir  = $puppet::ssldir,
  $rundir  = $puppet::rundir,
  $confdir = $puppet::confdir,
  $user    = $puppet::user,
  $group   = $puppet::group,
  $conf    = $puppet::conf,
) inherits puppet {
  include puppet::params

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
}
