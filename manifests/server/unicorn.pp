class puppet::server::unicorn {

  include puppet::params
  nginx::vhost {
    "puppetmaster_unicorn":
      port     => 8140,
      template => "puppet/nginx-unicorn.vhost.conf.erb"
  }

  unicorn::app {
    "puppetmaster":
      approot                  => $::puppet::params::puppet_confdir,
      config_file              => "${::puppet::params::puppet_confdir}/unicorn.conf",
      initscript               => $puppet::params::unicorn_initscript,
      unicorn_pidfile          => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.pid",
      unicorn_socket           => "${puppet::params::puppet_rundir}/puppetmaster_unicorn.sock",
      unicorn_worker_processes => '4',
      stdlog_path              => $puppet::params::puppet_logdir,
      log_stds                 => 'true',
      rack_file                => 'puppet:///modules/puppet/config.ru',
  }

  motd::register{ 'Puppet Master on Unicorn': }

}
