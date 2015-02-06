class puppet::package::gentoo (
  $keywords,
  $use,
) {

  package_use { 'sys-apps/net-tools':
    use    => 'old-output',
    target => 'puppet',
    before => Package[$puppet::agent::package],
  }

  if $keywords {
    package_keywords { $puppet::agent::package:
      keywords => $keywords,
      target   => 'puppet',
      before   => Package[$puppet::agent::package],
    }
  }

  if $use {
    package_use { $puppet::agent::package:
      use    => $use,
      target => 'puppet',
      before => Package[$puppet::agent::package],
    }
  }

}
