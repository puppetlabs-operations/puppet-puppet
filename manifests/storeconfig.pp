# Class: puppet::storedconfiguration
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

  include puppet::params

  #$puppet::storeconfigs = 'true' # called from puppet::server only if storeconfigs is on

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
      'grayskull': {
        include puppet::storeconfig::grayskull
      }
      default: { err("Target storeconfigs backend \"$backend\" not implemented") }
    }
  }

  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '06',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf-master-storeconfigs.erb");
  }

}

