class puppet::rack {
File{mode=>'0755', owner=>'root', group=>'root'}
file { ["/etc/puppet/rack", "/etc/puppet/rack/public"]:
    ensure => directory,
  }
  file { "/etc/puppet/rack/config.ru":
    source => "puppet:///modules/puppet/config.ru",
  } 
}
