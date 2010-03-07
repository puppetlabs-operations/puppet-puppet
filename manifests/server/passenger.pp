class puppet::server::passenger {
  include ::passenger
  require apache::ssl
  include puppet::server::rack
  apache::vhost{'puppetmaster':
    port => '8140',
    docroot => '/etc/puppet/rack/public/',
    webdir => '/etc/puppet/rack/',
    ssl => true,
    template => 'puppet/apache2.conf.erb',
  }
}
