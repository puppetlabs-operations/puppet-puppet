# == Class: puppet::server
#
# This class installs and configures a Puppet master
#
# == Description
#
# This class implements a Puppet master based around the dynamic environments
# workflow descripted in http://puppetlabs.com/blog/git-workflow-and-puppet-environments/
#
# ==  Parameters
#
# * modulepath
# * storeconfigs
# * dbadapter
# * dbuser
# * dbpassword
# * dbserver
# * dbsocket
# * servertype
#
# == Example
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
  $storeconfigs       = undef,
  $report             = 'true',
  $reports            = ["store", "https"],
  $reporturl          = "http://$fqdn/reports",
  $servertype         = "unicorn",
  $ca                 = false,
  $bindaddress        = '::',
  $enc                = '',
  $enc_exec           = '',
  $monitor_server     = hiera('puppet_server_monitor', 'true'),
  $backup_server      = hiera('puppet_server_backup', 'true'),
  $ensure             = 'present',
  $use                = "$puppet::params::master_use",
  $keywords           = '',
) {

  include puppet
  include puppet::package::server

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
    "standalone": {
      include puppet::server::standalone
    }
    default: {
      err('Only "passenger", "thin", and "unicorn" are valid options for servertype')
      fail("Servertype \"$servertype\" not implemented")
    }
  }

  # ---
  # Storeconfigs
  if $storeconfigs {
    class { "puppet::storeconfig":
      backend => $storeconfigs,
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
  if $backup_server == 'true' { include puppet::server::backup }

  concat::fragment { 'puppet.conf-master':
    order   => '05',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/master.erb");
  }

  # ---
  # If the server type is rack based, configure the config.ru
  case $servertype {
    'unicorn', 'thin': {
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
          /^3.[0|1]/ => 'puppet:///modules/puppet/config.ru/99-run-3.0.rb',
        },
      }
    }
  }

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

    if $ca == true {
      @@nagios_service { "check_certs_${hostname}":
        use                 => 'generic-service',
        check_command       => 'check_nrpe_1arg!check_certs',
        host_name           => $fqdn,
        service_description => "check_certs_${hostname}",
        target              => '/etc/nagios3/conf.d/nagios_service.cfg',
        notify              => Service[$nagios::params::nagios_service],
      }

      @@nagios_servicedependency {"check_certs_${hostname}":
        host_name                     => "$fqdn",
        service_description           => "check_ping_${hostname}",
        dependent_host_name           => "$fqdn",
        dependent_service_description => "check_certs_${hostname}",
        execution_failure_criteria    => "n",
        notification_failure_criteria => "w,u,c",
        ensure                        => present,
        target                        => '/etc/nagios3/conf.d/nagios_servicedep.cfg',
      }
    }
  }
}
