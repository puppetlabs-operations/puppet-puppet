class puppet::server::unicorn {

  include nginx::server
  nginx::vhost {
    "puppetmaster_unicorn":
      port     => 8140,
      template => "puppet/nginx-unicorn.vhost.conf.erb"
  }

  unicorn::app {
    "puppetmaster":
      approot                  => "/etc/puppet",
      config_file              => "/etc/puppet/unicorn.conf",
      initscript               => "puppet/unicorn_puppetmaster",
      unicorn_pidfile          => '/var/run/puppet/puppetmaster_unicorn.pid',
      unicorn_socket           => '/var/run/puppet/puppetmaster_unicorn.sock',
      unicorn_worker_processes => '4',
      rack_file                => 'puppet:///modules/puppet/config.ru',
  }

  #   file {
  #    "/etc/puppet/unicorn.conf":
  #    owner  => root,
  #    group  => root,
  #    mode   => 644,
  #    source => "puppet:///modules/puppet/unicorn.conf";
  #}

}

