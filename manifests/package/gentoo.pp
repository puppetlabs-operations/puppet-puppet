class puppet::package::gentoo {

  include puppet::agent
  include puppet::params

  if $puppet::server::master {
    include puppet::server
    $keywords = $puppet::server::gentoo_keywords
    $package  = $puppet::params::master_package
    $use      = $puppet::server::gentoo_use
  } else {
    $keywords = $puppet::agent::gentoo_keywords
    $package  = $puppet::params::agent_package
    $use      = $puppet::agent::gentoo_use
  }

  package_use { 'sys-apps/net-tools':
    use    => 'old-output',
    target => 'puppet',
    before => Package[$package],
  }

  package_keywords { $package:
    keywords => $keywords,
    target   => 'puppet',
    before   => Package[$package],
  }

  package_use { $package:
    use    => $use,
    target => 'puppet',
    before => Package[$package],
  }

}
