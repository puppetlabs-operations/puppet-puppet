class puppet::package::gentoo (
  $keywords,
  $use,
) {

  include puppet::params

  if $puppet::server::master {
    $package  = $puppet::params::master_package
    $real_use = $use ? {
      undef   => '-minimal',
      default => $use,
    }
  } else {
    $package  = $puppet::params::agent_package
    $real_use = $use ? {
      undef   => 'minimal',
      default => $use,
    }
  }

  package_use { 'sys-apps/net-tools':
    use    => 'old-output',
    target => 'puppet',
    before => Package[$package],
  }

  if $keywords {
    package_keywords { $package:
      keywords => $keywords,
      target   => 'puppet',
      before   => Package[$package],
    }
  }

  package_use { $package:
    use    => $use,
    target => 'puppet',
    before => Package[$package],
  }

}
