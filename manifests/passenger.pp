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
  include apache::mod::ssl
  include ::passenger
  include passenger::params

  file { ['/etc/puppet/rack', '/etc/puppet/rack/public', '/etc/puppet/rack/tmp']:
      owner  => 'puppet',
      group  => 'puppet',
      ensure => directory,
  }

  file { '/etc/puppet/rack/config.ru':
    owner    => 'puppet',
    group    => 'puppet',
    mode     => '0644',
    source   => $puppetversion ? {
      /^2.7/ => 'puppet:///modules/puppet/config.ru.passenger.27',
      /^3./  => 'puppet:///modules/puppet/config.ru.passenger.3',
    }
  }

  apache::vhost{ 'puppetmaster':
    port     => '8140',
    priority => '10',
    docroot  => '/etc/puppet/rack/public/',
    ssl      => true,
    template => 'puppet/vhost/apache/passenger.conf.erb',
  }
}
