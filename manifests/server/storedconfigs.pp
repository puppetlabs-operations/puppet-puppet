class puppet::server::storedconfigs inherits puppet::server {
  include rails    
  define puppetstoredb($dbuser = puppet, $dbpass = puppet, $dbserver = localhost, $socket = "/var/run/mysqld/mysqld.sock") {
    file { "${puppet::confd}/conf.d/storedconfigs":
      content  => template('puppet/storedconfigs.erb'),
      mode    => "644",
      owner   => "root",
      group   => "root",
      notify => Exec[rebuild-puppetconf] 
    }
    exec { "create-storeconfigs-db":
      command => "/usr/bin/mysqladmin create puppet",
      unless => "/usr/bin/mysqlcheck -s puppet",
      notify => Exec["create-storeconfigs-user"],
      require => Class['mysql::server']
    }
    exec { "create-storeconfigs-user":
      command         => "/usr/bin/mysql -e 'grant all privileges on puppet.* to puppet@localhost identified by \"$dbuser\"'",
      refreshonly     => true,
    }
  }  
}
