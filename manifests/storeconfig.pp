# Class: puppet::storeconfig
#
# This class installs and configures Puppet's stored configuration capability
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::storeconfig (
    $backend    = '',
    $dbuser     = 'puppet',
    $dbpassword = '',
    $dbserver   = 'localhost',
    $dbsocket   = ''
) {

  include puppet
  include puppet::params

  #$puppet::storeconfigs = 'true' # called from puppet::server only if storeconfigs is on

  Ini_setting {
    ensure  => 'present',
    section => 'master',
    path    => $puppet::params::puppet_conf,
  }

  if $backend != '' {
    ini_setting {
      'storeconfigs':
        setting => 'storeconfigs',
        value   => 'true';
      'thin_storeconfigs':
        setting => 'thin_storeconfigs',
        value   => 'true';
    }
  } else {
    ini_setting {
      'storeconfigs':
        setting => 'storeconfigs',
        value   => 'false';
      'thin_storeconfigs':
        ensure  => 'absent',
        setting => 'thin_storeconfigs';
    }
  }

  case $backend {
    "mysql","postgresql","sqlite": {
      package { "gem-activerecord":
        name => $operatingsystem ? {
          "Debian" => "libactiverecord-ruby",
          "Darwin" => "rb-activerecord",
          default  => activerecord,
        },
        provider => $operatingsystem ? {
          "Debian" => apt,
          "Darwin" => macports,
          default  => gem,
        },
      }
    }
  }

  case $backend {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      class { "puppet::storeconfig::mysql":
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
    }
    'postgresql': {
      class { "puppet::storeconfig::postgresql":
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
    }
    'puppetdb': {
      class {'::puppet::storeconfig::puppetdb': }
    }
    default: { err("Target storeconfigs backend \"$backend\" not implemented") }
  }
}
