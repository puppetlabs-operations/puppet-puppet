class puppet {
  package{'puppet':
    ensure => installed,
  }
  # I wont start puppet as a cron job, I trust our code :)
  service{'puppet':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }
  file{'/etc/puppet/puppet.conf':
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('puppet/puppet.conf.erb'),
    notify  => Service['puppet'],
    require => Package['puppet'],
  }
  # /etc/sysconfig/puppetmaster - what is this??
}
