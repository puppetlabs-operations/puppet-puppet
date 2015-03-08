class puppet::server::server {
  class { 'puppet::server::standalone': enabled => false }

  # configure
  # lol, no idea, really :(

  service { $puppet::params::server_service:
    ensure => $puppet::server::ensure
  }

}
