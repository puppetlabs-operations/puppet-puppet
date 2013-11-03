class puppet::server::standalone (
  $enabled = true
) {

  include puppet
  include puppet::server

  service { $puppet::params::master_service:
    ensure    => $enabled ? {true => running, false => stopped},
    enable    => $enabled,
    hasstatus => true,
    require   => Class['puppet::server::config'];
  }

  if ! $enabled {
    case $::lsbdistid {
      'Ubuntu': {
        file_line { '/etc/default/puppetmaster START':
          path    => '/etc/default/puppetmaster',
          line    => 'START=no',
          match   => '^START=',
          require => Package[$puppet::params::master_package],
        }
      }
    }
  }
}
