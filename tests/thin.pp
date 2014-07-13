host { 'puppet':
  ensure => 'present',
  ip     => $::ipaddress,
  target => '/etc/hosts',
}

class { 'puppet::server':
  servertype   => 'thin',
  ca           => true,
}
