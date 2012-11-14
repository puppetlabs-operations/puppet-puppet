# == Class: puppet::package::repository
#
# Add Puppet Labs package repositories
#
# == Parameters
#
# [*devel*]
#   Include development repositories for bleeding edge releases.
#   Default: false
#
# == Requirements
#
# If used on apt based distributions, this requires the puppetlabs/apt module.
#
class puppet::package::repository($devel = false) {
  case $osfamily {
    Redhat: {
      class { "puppetlabs_yum":
        enable_devel   => $devel,
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
