class puppet::server::standalone (
  $enabled = true
) {

  include puppet
  include puppet::server

  $service_ensure = $enabled? {
    true    => running,
    default => stopped,
  }

  service { $puppet::params::master_service:
    ensure    => $service_ensure,
    enable    => $enabled,
    hasstatus => true,
    require   => Class['puppet::server::config'];
  }

  if ! $enabled and $::lsbdistid == 'Ubuntu' {
    file_line { '/etc/default/puppetmaster START':
      path    => '/etc/default/puppetmaster',
      line    => 'START=no',
      match   => '^START=',
      require => Package[$puppet::params::master_package],
    }
  }
}
