# Class: puppet
#
# This class installs and configures Puppet
#
# Parameters:
# * server: name of the master to connect to
# * agent: should we run an agent, or cron your mother
#
# Actions:
# - Install Puppet
#
# Requires:
#
# Sample Usage:
#
class puppet (
    $server,
    $agent = true
  ) {
  include ruby
  include puppet::params
  include concat::setup

  $puppet_server   = $server
  $puppet_storedconfig_password = $puppet::params::puppet_storedconfig_password
  $puppetd_service = $puppet::params::puppetd_service
  $puppet_conf     = $puppet::params::puppet_conf
  $puppet_logdir   = $puppet::params::puppet_logdir
  $puppet_vardir   = $puppet::params::puppet_vardir
  $puppet_ssldir   = $puppet::params::puppet_ssldir

  if $kernel != "Darwin" and $kernel != "FreeBSD" {
    package { 'puppet':
      ensure => latest,
    }
    package { 'facter':
      ensure => latest,
    }
  }

  case $kernel {
    linux: {
      file { $puppet::params::puppetd_defaults:
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
        source => "puppet:///modules/puppet/${puppet::params::puppetd_defaults}",
      }
      $puppet_path = '/usr/bin/puppet'
    }
    darwin: {
      file { "com.puppetlabs.puppet.plist":
        owner   => root,
        group   => 0,
        mode    => 0640,
        source  => "puppet:///modules/puppet/com.puppetlabs.puppet.plist",
        path    => "/Library/LaunchDaemons/com.puppetlabs.puppet.plist",
      }
      $puppet_path = '/opt/local/bin/puppet'
    }
    freebsd: {
      $puppet_path = '/usr/local/bin/puppet'
    }
  }

  if $agent == true {
    service { "puppetd":
      name       => $puppetd_service,
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
    class { "puppet::monitor": enable => true; }
  } else {
    service { "puppetd":
      name       => $puppetd_service,
      ensure     => stopped,
      enable     => false,
      hasstatus  => true,
      hasrestart => true,
      require    => Cron["puppet agent"],
    }
    cron {
      "puppet agent":
        command => "${puppet_path} agent --onetime --no-daemonize >/dev/null",
        minute  => "*/30";
    }
    class { "puppet::monitor": enable => false; }
  }

  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf-common.erb");
  }

  concat { $puppet::params::puppet_conf:
    mode    => '0644',
  }

}

