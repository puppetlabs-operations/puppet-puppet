class puppet::package {

  include puppet::package::repository

  if $::operatingsystem == 'gentoo' {
    package_use { 'sys-apps/net-tools':
      use    => 'old-output',
      target => 'puppet',
    }
  }

  # Fixes a bug. #12813
  class { '::puppet::package::patches': }
}
