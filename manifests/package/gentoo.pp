class puppet::package::gentoo {

  package_use { 'sys-apps/net-tools':
    use    => 'old-output',
    target => 'puppet',
  }

  if $puppet::server::master {
    $keywords = $puppet::server::gentoo_keywords
    $package  = $puppet::params::master_package
    $use      = $puppet::server::gentoo_use
    $ensure   = $puppet::server::ensure
  } else {
    $keywords = $puppet::agent::gentoo_keywords
    $package  = $puppet::params::agent_package
    $use      = $puppet::agent::gentoo_use
    $ensure   = $puppet::agent::ensure
  }

  if $keywords {
    package_keywords { 'dev-ruby/hiera':
      keywords => $keywords,
      target   => 'puppet',
      before   => Portage::Package[$package],
    }
    package_keywords { 'app-vim/puppet-syntax':
      keywords => $keywords,
      target   => 'puppet',
      before   => Portage::Package[$package],
    }
  }

  portage::package { $package:
    keywords => $keywords,
    use      => $use,
    target   => 'puppet',
    ensure   => $ensure,
  }
}
