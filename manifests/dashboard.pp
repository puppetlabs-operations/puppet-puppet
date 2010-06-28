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
  include ::passenger
  include passenger::params
  include ruby::dev
  include mysql::server

  $passenger_version=$passenger::params::version
  $gem_path=$passenger::params::gem_path

  package { 'puppet-dashboard':
    ensure => present,
  }

  file { '/usr/share/puppet-dashboard/config/database.yml':
    ensure => present,
    content => template('puppet/database.yml.erb'),
    require => Package['puppet-dashboard'],
  }  

  file { '/usr/share/puppet-dashboard/public/.htaccess':
    ensure => present,
    source => 'puppet:///modules/puppet/.htaccess',
    require => Package['puppet-dashboard'],
  }


  #cron { 'dashboard_report_import':
  #  command => 'cd /usr/share/puppet-dashboard; RAILS_ENV=production rake reports:import',
  #  user => 'root',
  #  minute => '*/30', 
  #  require => Package['puppet-dashboard'],
  #}

  apache::vhost { $dashboard_site:
    port => '80',
    priority => '50',
    docroot => '/usr/share/puppet-dashboard/public',
    template => 'puppet/puppet-dashboard-passenger.conf.erb',
  }
}

