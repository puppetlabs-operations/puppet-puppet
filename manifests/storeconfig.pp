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
    $dbuser     = '',
    $dbpassword = '',
    $dbserver   = '',
    $dbsocket   = ''
  ) {

  $storeconfigs = 'true' # called from puppet::server only if storeconfigs is on

  case $dbadapter {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      include puppet::storeconfig::mysql
    }
    default: { err("targer dbadapter $dbadapter not implemented") }
  }

  concat::fragment { 'puppet.conf-header':
    order   => '01',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs.erb");
  }

}

