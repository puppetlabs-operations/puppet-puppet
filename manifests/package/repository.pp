class puppet::package::repository($devel = hiera('puppet_package_devel', false)) {

  case $osfamily {
    Redhat: {
      yumrepo { 'puppetlabs':
        descr      => "Puppet Labs",
        baseurl    => "http://yum.puppetlabs.com/el/5/products/$architecture/",
        enabled    => 1,
        gpgcheck   => 1,
        keepalive  => 1,
        gpgkey     => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs'
      }

      yumrepo { 'puppetlabs-deps':
        descr      => "Puppet Labs",
        baseurl    => "http://yum.puppetlabs.com/el/5/dependencies/$architecture/",
        enabled    => 1,
        gpgcheck   => 1,
        keepalive  => 1,
        gpgkey     => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs'
      }
    }
    Debian: {
      $repo_list = $devel ? {
        true  => 'main dependencies devel',
        false => 'main dependencies',
      }

      apt::source { "puppetlabs":
        location   => "http://apt.puppetlabs.com/",
        key        => '4BD6EC30',
        key_source => 'http://apt.puppetlabs.com/pubkey.gpg',
        pin        => '900',
        repos      => $repo_list,
      }

      package{ "puppetlabs-release":
        ensure  => installed,
        require => Apt::Source["puppetlabs"],
      }
    }
  }
}
