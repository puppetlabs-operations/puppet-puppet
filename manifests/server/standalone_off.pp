class puppet::server::standalone_off {
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
