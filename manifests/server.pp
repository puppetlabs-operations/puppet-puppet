# Class: puppet::server
#
# This class installs and configures a Puppet master
#
# Parameters:
# * modulepath
# * storeconfigs
# * dbadapter
# * dbuser
# * dbpassword
# * dbserver
# * dbsocket
# * certname
# * servertype
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  $modulepath = [
#    "/etc/puppet/modules/site",
#    "/etc/puppet/modules/dist",
#  ]
#
#  class { "puppet::server":
#    modulepath => inline_template("<%= modulepath.join(':') %>"),
#    reporturl  => "https://dashboard.puppetlabs.com/reports";
#  }
#
class puppet::server (
    $modulepath         = '$confdir/modules/site:$confdir/env/$environment/dist',
    $manifest           = '$confdir/modules/site/site.pp',
    $config_version_cmd = '/usr/bin/git --git-dir $confdir/environments/$environment/.git rev-parse --short HEAD 2>/dev/null || echo',
    $storeconfigs       = hiera('puppet_storeconfigs'),
    $dbadapter          = 'sqlite3',
    $dbuser             = 'puppet',
    $dbpassword         = 'password',
    $dbserver           = 'localhost',
    $dbsocket           = '/var/run/mysqld/mysqld.sock',
    $certname           = "$fqdn",
    $report             = 'true',
    $reports            = ["store", "https"],
    $reporturl          = "http://$fqdn/reports",
    $servertype         = "unicorn",
    $ca                 = false
  ) {

  include puppet::params

  # ---
  # The site.pp is set in the puppet.conf, remove site.pp here to avoid confusion
  file { "${puppet::params::puppet_confdir}/manifests/site.pp": ensure => absent; }

  # ---
  # Application-server specific SSL configuration
  case $servertype {
    "passenger": {
      include puppet::server::passenger
      $ssl_client_header        = "SSL_CLIENT_S_DN"
      $ssl_client_verify_header = "SSL_CLIENT_VERIFY"
    }
    "unicorn": {
      include puppet::server::unicorn
      $ssl_client_header        = "HTTP_X_CLIENT_DN"
      $ssl_client_verify_header = "HTTP_X_CLIENT_VERIFY"
    }
    "thin": {
      include puppet::server::thin
      $ssl_client_header        = "HTTP_X_CLIENT_DN"
      $ssl_client_verify_header = "HTTP_X_CLIENT_VERIFY"
    }
    default: {
      err('Only "passenger", "thin", and "unicorn" are valid options for servertype')
      fail("Servertype \"$servertype\" not implemented")
    }
  }

  # ---
  # Storeconfigs
  case $storeconfigs {
    "mysql","postgresql","sqlite","puppetdb": {
      class { "puppet::storeconfig":
        backend    => $storeconfigs,
        dbuser     => $dbuser,
        dbpassword => $dbpassword,
        dbserver   => $dbserver,
        dbsocket   => $dbsocket
      }
    }
    default: {
      notify { "puppet::server storeconfigs => $storeconfigs option not recognized": }
    }
  }

  # ---
  # Backups
  #
  # FIXME
  # http://projects.puppetlabs.com/issues/10590
  # err: Could not retrieve catalog from remote server: Error 400 on SERVER: can't clone TrueClass
  #
  # Use a real boolean after hiera 1.0 is out
  #
  $backup_server = hiera('puppet_server_backup', 'true')
  if $backup_server == 'true' { include puppet::server::backup }

  # ---
  # Used only for platforms that seperate the master and agent packages
  if $puppet::params::master_package != '' {
    package { $puppet::params::master_package: ensure => present; }
  }

  if $puppet::params::master_service != '' {
    service { $puppet::params::master_service:
      ensure    => stopped,
      enable    => false,
      hasstatus => true,
      require   => File[$puppet::params::puppet_conf];
    }
  }

  # ---
  # Write the server configuration items
  concat::fragment { 'puppet.conf-master':
    order   => '05',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/master.erb");
  }

  concat { "${::puppet::params::puppet_confdir}/config.ru":
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    notify => Nginx::Vhost['puppetmaster'],
  }

  concat::fragment { "run-puppet-master":
    order  => '99',
    target => "${::puppet::params::puppet_confdir}/config.ru",
    source => 'puppet:///modules/puppet/config.ru/99-run.rb',
  }


  # Nagios!
  # FIXME
  # http://projects.puppetlabs.com/issues/10590
  # err: Could not retrieve catalog from remote server: Error 400 on SERVER: can't clone TrueClass
  #
  # Use a real boolean after hiera 1.0 is out
  #
  $monitor_server = hiera('puppet_server_monitor', 'true')

  if $monitor_server == 'true' {
    @@nagios_service { "check_puppetmaster_${hostname}":
      use                 => 'generic-service',
      check_command       => 'check_puppetmaster',
      host_name           => $fqdn,
      service_description => "check_puppetmaster_${hostname}",
      target              => '/etc/nagios3/conf.d/nagios_service.cfg',
      notify              => Service[$nagios::params::nagios_service],
    }

    @@nagios_servicedependency {"check_puppetmaster_${hostname}":
      host_name                     => "$fqdn",
      service_description           => "check_ping_${hostname}",
      dependent_host_name           => "$fqdn",
      dependent_service_description => "check_puppetmaster_${hostname}",
      execution_failure_criteria    => "n",
      notification_failure_criteria => "w,u,c",
      ensure                        => present,
      target                        => '/etc/nagios3/conf.d/nagios_servicedep.cfg',
    }
  }
}
