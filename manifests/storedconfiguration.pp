# Class: puppet::storedconfiguration
#
# This class installs and configures Puppet's stored configuration capability
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::storedconfiguration {

   $rails_version = '2.3.5'
   require rails
   require mysql::server
   require puppet::server

   $puppet_storedconfig_password = $puppet::params::puppet_storedconfig_password
 
   package { $puppet::params::puppet_storedconfig_packages:
     ensure => installed,
   }

   package { 'mysql':
     ensure => installed,
     provider => 'gem',
   }

   database{ 'puppet':
     ensure => present,
     charset   => 'utf8',
   }

   database_user{'puppet@localhost':
     ensure => present,
     password_hash => mysql_password($puppet_storedconfig_password),
     require => Database['puppet'],
   }
 
   database_grant{ 'puppet@localhost/puppet':
     privileges => [all],
     require => [ Database['puppet'], Database_user['puppet@localhost'] ],
   }

}
