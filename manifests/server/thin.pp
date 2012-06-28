class puppet::server::thin {

  include puppet::params

  nginx::vhost { "puppetmaster":
    port     => 8140,
    template => "puppet/vhost/nginx/base.conf.erb",
  }

  concat::fragment { "proctitle":
    order  => '05',
    target => "${::puppet::params::puppet_confdir}/config.ru",
    source => 'puppet:///modules/puppet/config.ru/05-proctitle.rb',
  }

  thin::app { 'puppetmaster':
    user    => 'puppet',
    group   => 'puppet',
    rackup  => "${::puppet::params::puppet_confdir}/config.ru",
    chdir   => $puppet::params::puppet_confdir,
  }

  motd::register {"Puppet master on Thin": }
}
