class puppet::package($ensure = 'latest') {

  include puppet::params
  require puppet::package::repository

  # ----
  # Be carefull about systems that may not be able to upgrade cleanly
  if $puppet::params::update_puppet {
    package { 'puppet': ensure => $ensure; }
    package { 'facter': ensure => $ensure; }

    # Fixes a bug. #12813
    class { '::puppet::package::patches': }
  }
}
