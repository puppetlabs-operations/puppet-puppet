class puppet::package {

  if $puppet::agent::manage_repos {
    include puppet::package::repository
  }

  if $::operatingsystem == 'gentoo' {
    include puppet::package::gentoo
  }

  package { $puppet::agent::package:
    ensure => $puppet::agent::ensure;
  }

  if $puppet::server::master and ($puppet::server::package != $puppet::agent::package) {
    package { $puppet::server::package:
      ensure => $puppet::server::ensure;
    }
  }

}
