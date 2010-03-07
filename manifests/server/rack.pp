class puppet::server::rack {
  include ::rack
  include puppet::server
  File{mode=>'0755', owner=>'root', group=>'root'}
  file { ["/etc/puppet/rack", "/etc/puppet/rack/public"]:
    ensure => directory,
    require => Package['puppet-server'],
  }
  file { "/etc/puppet/rack/config.ru":
    source => "puppet:///modules/puppet/config.ru",
  } 
}
