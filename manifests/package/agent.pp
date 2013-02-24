class puppet::package::agent inherits puppet::package {

  if $::operatingsystem == 'gentoo' {
    if $puppet::agent::keywords {
      package_keywords { 'dev-ruby/hiera':
        keywords => $puppet::agent::keywords,
        target   => 'puppet',
        before   => Portage::Package[$puppet::params::agent_package],
      }
      package_keywords { 'app-vim/puppet-syntax':
        keywords => $puppet::agent::keywords,
        target   => 'puppet',
        before   => Portage::Package[$puppet::params::agent_package],
      }
    }

    portage::package { $puppet::params::agent_package:
      keywords => $puppet::agent::keywords,
      use      => $puppet::agent::use,
      target   => 'puppet',
      ensure   => $puppet::agent::ensure,
    }
  }
  else {
    package { $puppet::params::agent_package:
      ensure => $puppet::agent::ensure,
    }
  }
}
