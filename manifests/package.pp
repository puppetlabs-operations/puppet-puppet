class puppet::package {

  include puppet::params
  include puppet::package::repository

  package { $puppet::params::agent_package:
    ensure => $puppet::agent::ensure;
  }

  # Fixes a bug. #12813
  class { '::puppet::package::patches': }
}
