class puppet::storeconfig::mysql (
    $dbuser,
    $dbpassword
  ){

  include puppet::params

  #  if $kernel == "Linux" {
  #    package { $puppet::params::puppet_storedconfig_packages:
  #      ensure => installed,
  #    }
  #  }

  concat::fragment { 'puppet.conf-master-storeconfig-mysql':
    order   => '07',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs-mysql.erb");
  }

  package { "gem-mysql":
    name => $operatingsystem ? {
      "Debian" => "libmysql-ruby",
      "Darwin" => "rb-mysql",
      default  => mysql,
    },
    provider => $operatingsystem ? {
      "Debian" => apt,
      "Darwin" => macports,
      default  => gem,
    },
    ensure => installed,
  }

   database{ 'puppet':
     ensure  => present,
     charset => 'utf8',
   }

   database_user{"$dbuser@localhost":
     ensure        => present,
     password_hash => mysql_password($dbpassword),
     require       => Database['puppet'],
   }
 
   database_grant{ 'puppet@localhost/puppet':
     privileges => [all],
     require    => [ Database['puppet'], Database_user['puppet@localhost'] ],
   }


}
