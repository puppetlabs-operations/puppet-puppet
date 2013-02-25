# == Class: puppet::package::repository
#
# Add Puppet Labs package repositories
#
# == Parameters
#
# [*devel*]
#   Include development repositories for bleeding edge releases.
#   Default: false
#
# == Requirements
#
# If used on apt based distributions, this requires the puppetlabs/apt module.
#
class puppet::package::repository($devel = false) {
  case $osfamily {
    Redhat: {
      class { 'puppetlabs_yum':
        enable_devel   => $devel,
      }
    }
    Debian: {
      class { 'puppetlabs_apt':
        enable_devel => $devel,
      }
    }
  }
}
