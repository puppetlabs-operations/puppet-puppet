class puppet::package {

  include puppet::params

  # ----
  # Be carefull about systems that may not be able to upgrade cleanly
  if $puppet::params::update_puppet {
    package { 'puppet': ensure => latest; }
    package { 'facter': ensure => latest; }

    # Fixes a bug. #12813
    class { '::puppet::package::patches': }
  }

}
