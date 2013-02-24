class puppet::package::agent inherits puppet::package {

  package { $puppet::params::agent_package:
    ensure => $puppet::agent::ensure,
  }
}
