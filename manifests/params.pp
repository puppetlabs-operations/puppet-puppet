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

 case $operatingsystem {
    "centos": {
      $puppetmaster_package="puppet-server"
      $puppemasterd_service="puppetmasterd"
      $puppetd_service="puppetd"
    }
    "ubuntu": {
      $puppetmaster_package="puppetmaster"
      $puppemasterd_service="puppetmaster"
      $puppetd_service="puppet"
    }
 }
  
}
