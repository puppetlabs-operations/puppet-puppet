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
    $dbadapter,
    $dbuser     = 'puppet',
    $dbpassword = 'password',
    $dbserver   = 'localhost',
    $dbsocket   = ''
  ) {

  $storeconfigs = 'true' # called from puppet::server only if storeconfigs is on

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
    }
  }


  case $dbadapter {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      class { 
        "puppet::storeconfig::mysql": 
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
    }
    default: { err("targer dbadapter $dbadapter not implemented") }
  }

  concat::fragment { 'puppet.conf-master-storeconfig':
    order   => '06',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs.erb");
  }

}

