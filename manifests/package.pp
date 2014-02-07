class puppet::package {

  include puppet::agent
  include puppet::params

  if $puppet::agent::manage_repos {
    include puppet::package::repository
  }

  if $::operatingsystem == 'gentoo' {
    include puppet::package::gentoo
  }

  package { $puppet::params::agent_package:
    ensure => $puppet::agent::ensure;
  }

  if $puppet::server::master and ($puppet::params::master_package != $puppet::params::agent_package) {
    package { $puppet::params::master_package:
      ensure => $puppet::server::ensure;
    }
  }

  # Fixes a bug. #12813
  class { '::puppet::package::patches': }
}
