class puppet::package {

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

}
