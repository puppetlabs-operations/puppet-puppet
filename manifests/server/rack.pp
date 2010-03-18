class puppet::server::rack {
  include ::rack
  include puppet::server
  # this will be 755 for dir
  File{mode=>'0644', owner=>'puppet', group=>'puppet'}
  file { ['/etc/puppet/rack', '/etc/puppet/rack/public']:
    ensure => directory,
    require => Package['puppet-server'],
  }
  file { '/etc/puppet/rack/config.ru':
    source => 'puppet:///modules/puppet/config.ru',
  } 
}
