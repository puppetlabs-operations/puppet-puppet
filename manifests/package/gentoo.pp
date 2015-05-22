# == Class: puppet::package::gentoo
#
# Additional configuration needed for Gentoo. This class is private. Its
# parameters should be set in hieradata
#
# == Parameters
#
# [*keywords*]
# ACCEPT_KEYWORDS for the puppet package
#
# [*use*]
# USE flags for the puppet package
#
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
