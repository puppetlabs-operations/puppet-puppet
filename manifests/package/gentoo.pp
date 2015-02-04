class puppet::package::gentoo {

  include puppet::agent

  if $puppet::server::master {
    include puppet::server
    $keywords = $puppet::server::gentoo_keywords
    $package  = $puppet::server::package
    $use      = $puppet::server::gentoo_use
  } else {
    $keywords = $puppet::agent::gentoo_keywords
    $package  = $puppet::agent::package
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
