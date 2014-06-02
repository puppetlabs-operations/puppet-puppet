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

  # if no backend was selected
  $thin_enable = $backend ? {
    ''      => true,
    default => false,
  }
  $thin_ensure = $backend ? {
    ''      => 'present',
    default => 'absent',
  }

  # use thin_storageconfigs
  ini_setting {
    'storeconfigs':
      setting => 'storeconfigs',
      value   => $thin_enable;
    'thin_storeconfigs':
      ensure  => $thin_ensure,
      setting => 'thin_storeconfigs',
      value   => $thin_enable;
  }

  case $backend {
    'mysql','postgresql','sqlite': {

      # this is not pretty, and could be put into params..

      $package_name = $::operatingsystem ? {
        'Debian' => 'libactiverecord-ruby',
        'Darwin' => 'rb-activerecord',
        default  => 'activerecord',
      }
      $package_provider = $::operatingsystem ? {
        'Debian' => 'apt',
        'Darwin' => 'macports',
        default  => 'gem',
      }

      package { 'gem-activerecord':
        name     => $package_name,
        provider => $package_provider,
      }
    }
  }

  case $backend {
    'sqlite3': {
      include puppet::storeconfig::sqlite
    }
    'mysql': {
      class { 'puppet::storeconfig::mysql':
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
    }
    'postgresql': {
      class { 'puppet::storeconfig::postgresql':
          dbuser     => $dbuser,
          dbpassword => $dbpassword,
      }
    }
    'puppetdb': {
      class {'::puppet::storeconfig::puppetdb': }
    }
    default: { err('Target storeconfigs backend "$backend" not implemented') }
  }
}
