class puppet::server::passenger inherits puppet::server {
  include ::passenger
  require apache::ssl
  include puppet::server::rack
  include ::passenger::params
  $passenger_version=$::passenger::params::version
  Service['puppetmaster']{
    enable => false,
    ensure => stopped,
  }
  apache::vhost{'puppetmaster':
    port => '8080',
    docroot => '/etc/puppet/rack/public/',
    webdir => '/etc/puppet/rack/',
    ssl => true,
    template => 'puppet/apache2.conf.erb',
    require => Service['puppetmaster'],
  }
}
