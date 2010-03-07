class puppet::server inherits puppet {
  package{'puppet-server':
    ensure => installed,
  }
  service{'puppetmaster':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
  file{'/etc/puppet/namespaceauth.conf':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/puppet/namespaceauth.conf',
  }
#  File['/etc/puppet/puppet.conf'] {
#    content => template('puppet/puppet.conf.erb'),
#    notify  +> Service['puppetmaster'],
#  }
  # /etc/sysconfig/puppetmaster - what is this??
}
