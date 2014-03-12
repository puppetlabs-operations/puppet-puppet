class puppet::server::thin {

  include puppet::params
  include puppet::server::rack

  class { 'puppet::server::standalone': enabled => false }

  $servers = $::processorcount
  nginx::vhost { "puppetmaster":
    port     => 8140,
    template => "puppet/vhost/nginx/thin.conf.erb",
  }

  concat::fragment { "proctitle":
    order  => '05',
    target => "${::puppet::params::puppet_confdir}/config.ru",
    source => 'puppet:///modules/puppet/config.ru/05-proctitle.rb',
  }

  thin::app { 'puppetmaster':
    user      => 'puppet',
    group     => 'puppet',
    rackup    => "${::puppet::params::puppet_confdir}/config.ru",
    chdir     => $puppet::params::puppet_confdir,
    subscribe => Concat["${::puppet::params::puppet_confdir}/config.ru"],
  }
}
