# Class: puppet::params
#
# This class installs and configures parameters for Puppet
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::params {

 $puppet_server = 'baal.puppetlabs.com'
 $puppet_storedconfig_password = 'password'

 case $operatingsystem {
    'centos', 'redhat', 'fedora': {
      $puppetmaster_package='puppet-server'
      $puppemasterd_service='puppetmasterd'
      $puppetd_service='puppetd'
      $puppetd_defaults='/etc/sysconfig/puppet'
      $puppet_dashboard_report=''
      $puppet_storedconfig_packages='mysql-devel'
    }
    'ubuntu', 'debian': {
      $puppetmaster_package='puppetmaster'
      $puppemasterd_service='puppetmaster'
      $puppetd_service='puppet'
      $puppetd_defaults='/etc/default/puppet'
      $puppet_dashboard_report='/usr/lib/ruby/1.8/puppet/reports/puppet_dashboard.rb'
      $puppet_storedconfig_packages='libmysql-ruby'
    }
 }
  
}
