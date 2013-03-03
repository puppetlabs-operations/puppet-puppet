# == Class: puppet::package::server
#
# Handle the puppet server package installation.
#
class puppet::package::server inherits puppet::package {

  if $::operatingsystem == 'gentoo' {
    if $puppet::server::keywords {
      package_keywords { 'dev-ruby/hiera':
        keywords => $puppet::server::keywords,
        target   => 'puppet',
        before   => Portage::Package[$puppet::params::master_package],
      }
      package_keywords { 'app-vim/puppet-syntax':
        keywords => $puppet::server::keywords,
        target   => 'puppet',
        before   => Portage::Package[$puppet::params::master_package],
      }
    }

    portage::package { $puppet::params::master_package:
      keywords => $puppet::server::keywords,
      use      => $puppet::server::use,
      target   => 'puppet',
      ensure   => $puppet::server::ensure,
    }
  }
  else {
    package { $puppet::params::master_package:
      ensure => $puppet::server::ensure,
    }
  }
}
