class puppet::passenger {
  include ruby::dev
  include apache::ssl
  include ::passenger
  include passenger::params
  include ::rack

  $passenger_version=$passenger::params::version
  
  file { ['/etc/puppet/rack', '/etc/puppet/rack/public', '/etc/puppet/rack/tmp']:
    owner => "puppet",
    group => "puppet",
    ensure => directory,
  }
  file { '/etc/puppet/rack/config.ru':
    owner => "puppet",
    group => "puppet",
    mode => 0644,
    source => 'puppet:///modules/puppet/config.ru',
  }

  apache::vhost{'puppetmaster':
    port => '8140',
    docroot => '/etc/puppet/rack/public/',
    webdir => '/etc/puppet/rack/',
    ssl => true,
    template => 'puppet/apache2.conf.erb',
  }
}
