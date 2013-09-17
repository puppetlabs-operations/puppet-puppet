# == Class: puppet::server::rack
#
# This class creates the config.ru filr that is necessary for rack based
# application servers.
#
# Application server classes that depend on this config.ru should include this
# class.
#
class puppet::server::rack {
  concat { "${::puppet::params::puppet_confdir}/config.ru":
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    notify => Nginx::Vhost['puppetmaster'],
  }

  concat::fragment { "run-puppet-master":
    order  => '99',
    target => "${::puppet::params::puppet_confdir}/config.ru",
    source => $puppetversion ? {
      /^2.7/ => 'puppet:///modules/puppet/config.ru/99-run-2.7.rb',
      /^3.[0-3]/ => 'puppet:///modules/puppet/config.ru/99-run-3.0.rb',
    },
  }
}
