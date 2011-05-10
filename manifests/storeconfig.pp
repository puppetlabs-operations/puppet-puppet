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
    $dbuser = '',
    $dbpassword = '',
    $dbserver = '',
    $dbsocket = ''
  ) {

  case $dbadapter {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      include puppet::storeconfig::mysql
    }
    default: { err("targer dbadapter not implemented") }
  }

}

