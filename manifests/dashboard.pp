# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::dashboard {
  include ruby::dev
  include mysql::server
  
  vcsrepo { '/opt/dashboard':
    source => 'git://github.com/reductivelabs/puppet-dashboard.git', 
    ensure => present,
  }

  package { [ 'mysql', 'has_scope' ]:
    ensure => present,
    provider => gem,
  } 

  #exec { 'rake install':
  #  path => '/opt/dashboard',
  #  creates => '/opt/dashboard/config/database.yml',
  #  require => [ Exec['rake gems:install'], Package['mysql'], Vcsrepo['/opt/dashboard'] ],
  #}
}
