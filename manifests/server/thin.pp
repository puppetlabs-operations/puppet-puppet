class puppet::server::thin {

  include puppet::params

  nginx::vhost { "puppetmaster_thin":
    port     => 8140,
    template => "puppet/vhost/nginx/thin.conf.erb",
  }

  file { "${::puppet::params::puppet_confdir}/config.ru":
    ensure => present,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    source => 'puppet:///modules/puppet/config.ru',
    before => Thin::App['puppetmaster'],
  }

  thin::app { 'puppetmaster':
    user    => 'puppet',
    group   => 'puppet',
    servers => 1,
    rackup  => "${::puppet::params::puppet_confdir}/config.ru",
  }

  motd::register {"Puppet master on Thin": }
}
