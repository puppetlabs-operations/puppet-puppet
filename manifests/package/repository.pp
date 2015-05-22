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

  case $::osfamily {
    'Redhat': { $repo_class = 'puppetlabs_yum' }
    'Debian': { $repo_class = 'puppetlabs_apt' }
    default: {}
  }

  if $::osfamily == 'Redhat' or $::osfamily == 'Debian' {
    class { $repo_class:
      enable_devel   => $devel,
    }
  }
}
