class puppet::package::server inherits puppet::package {

  package { $puppet::params::master_package:
    ensure => $puppet::server::ensure,
  }
}
