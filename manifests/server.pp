#
# configures the puppetmaster
#
class puppet::server inherits puppet {
 Exec ["rebuild-puppetconf"] { notify => Service["puppet","puppetmaster"] }
 $puppetlib = "/var/lib/puppet" 
 file { "${puppet::confd}/conf.d/server":
   source  => "puppet:///puppet/server",
   mode    => "644",
   owner   => "root",
   group   => "root",
   notify => Exec[rebuild-puppetconf] 
 }
  file    {
   "$puppetlib/rrd":
     ensure  => directory,
     mode    => "755",
     owner   => "puppet",
     group   => "puppet";
  ["$puppetlib/reports","$puppetlib/ssl","/var/log/puppet"]:
     ensure  => directory,
     mode    => "750",
     owner   => "puppet",
     group   => "puppet";
  ["$puppetlib","$puppetlib/manifests","$puppetlib/modules"]:
     ensure  => directory,
     mode    => "755",
     owner   => "root",
     group   => "root";
  "puppetmaster.init":
     ensure  => present,
     path    => "/etc/init.d/puppetmaster",
     source  => "puppet:///puppet/$operatingsystem/puppetmaster.init",
     mode    => "755",
     owner   => "root",
     group   => "root";
  "fileserver.conf":
     ensure  => present,
     path    => "/etc/puppet/fileserver.conf",
     source  => "puppet:///puppet/fileserver.conf",
     mode    => "644",
     owner   => "root",
     group   => "root";
  }
  service {"puppetmaster":
     enable  => true,
     ensure  => running,
     require => File["puppetmaster.init"],
     require => File["/var/lib/puppet"],
     require => File["/var/lib/puppet/modules"],
     require => File["/var/lib/puppet/manifests"],
  }

 define storeconfig($dbuser = puppet, $dbpass = puppet, $dbserver = localhost, $socket = "/var/run/mysqld/mysqld.sock") {
   include rails

   file { "${puppet::confd}/conf.d/storeconfig":
     content => template("puppet/storeconfig.erb"),
     mode    => "644",
     owner   => "root",
     group   => "root",
     notify => Exec[rebuild-puppetconf] 
   }

    exec { "create-storeconfigs-db":
      command => "/usr/bin/mysqladmin create puppet",
      unless  => "/usr/bin/mysqlcheck -s puppet",
      notify  => Exec["create-storeconfigs-user"],
      require => Class['mysql::server']
    }

    exec { "create-storeconfigs-user":
      command => "/usr/bin/mysql -e 'grant all privileges on puppet.* to puppet@localhost identified by \"$dbuser\"'",
      refreshonly => true,
    }
  }
}
