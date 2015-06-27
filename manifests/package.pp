# Private class
class puppet::package {

  if $puppet::agent::manage_repos {
    include puppet::package::repository
  }

  if $::operatingsystem == 'gentoo' {
    include puppet::package::gentoo
  }

  package { $puppet::agent::package:
    ensure => $puppet::agent::ensure,
    notify => Service['puppet_agent'],
  }

}
