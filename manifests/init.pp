# configures puppet clients
class puppet {
  $confd = "/etc/puppet" 
  file    {
    "${puppet::confd}/conf.d":
      ensure => directory,
      purge => true;
    "puppet.init":
      path    => "/etc/init.d/puppet",
      source  => "puppet:///puppet/$operatingsystem/puppet.init",
      mode    => "755",
      owner   => "root",
      group   => "root";
    }

  # A simple exec that rebuilds puppet.conf file if any of the fragments change and restarts the service.

  exec { "rebuild-puppetconf":
    command => "/bin/cat ${puppet::confd}/conf.d/* > ${puppet::confd}/puppet.conf",
    refreshonly => true,
    subscribe => File["${puppet::confd}/conf.d"],
    notify => Service["puppet"]
  }

  # Simple management on the file itself.

  file { "${puppet::confd}/puppet.conf":  mode => 644, require => Exec[rebuild-puppetconf] }

  # Simple management of the file puppet client config stuff.

  file { "${puppet::confd}/conf.d/client": 
    source  => "puppet:///puppet/client",  
    mode    => "644",
    owner   => "root",
    group   => "root",
    notify => Exec[rebuild-puppetconf],
  }
  service { "puppet":
    enable      => true,
    ensure      => running,
    require     => File["puppet.init"],
    hasstatus   => true,
  }
}
