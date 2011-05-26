class puppet::storeconfig::mysql (
    $dbuser,
    $dbpassword
  ){

   package { $puppet::params::puppet_storedconfig_packages:
     ensure => installed,
   }

   package { 'mysql':
     ensure   => installed,
     provider => 'gem',
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
