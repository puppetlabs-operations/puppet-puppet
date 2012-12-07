# Class: puppet::passenger
#
# This class installs and configures Passenger for Puppet
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class puppet::passenger {
  include ruby::dev
  include apache::ssl
  include ::passenger
  include passenger::params

  $passenger_version=$passenger::params::version
  $gem_path=$passenger::params::gem_path

  file {
    ['/etc/puppet/rack', '/etc/puppet/rack/public', '/etc/puppet/rack/tmp']:
      owner  => 'puppet',
      group  => 'puppet',
      ensure => directory,
  }
  file {
    '/etc/puppet/rack/config.ru':
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0644',
      source => 'puppet:///modules/puppet/config.ru',
  }

  apache::vhost{ 'puppetmaster':
    port     => '8140',
    priority => '10',
    docroot  => '/etc/puppet/rack/public/',
    ssl      => true,
    template => 'puppet/vhost/apache/passenger.conf.erb',
  }
}
