class puppet::package {

  include puppet::params
  include puppet::package::repository

  package { 'puppet':
    ensure => $puppet::agent::ensure;
  }

  # Fixes a bug. #12813
  class { '::puppet::package::patches': }
}
