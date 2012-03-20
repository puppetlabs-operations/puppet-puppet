class puppet (
    $server        = hiera("puppet_server"),
    $manage_agent  = false
) {
  include puppet::params
  include concat::setup

  $puppet_server   = $server
  $agent_service   = $puppet::params::agent_service
  $puppet_conf     = $puppet::params::puppet_conf
  $puppet_logdir   = $puppet::params::puppet_logdir
  $puppet_vardir   = $puppet::params::puppet_vardir
  $puppet_ssldir   = $puppet::params::puppet_ssldir
  $puppet_cmd      = $puppet::params::puppet_cmd

  # ----
  # Be carefull about systems that may not be able to upgrade cleanly
  if $puppet::params::update_puppet {
    package { 'puppet': ensure => latest; }
    package { 'facter': ensure => latest; }

    # Fixes a bug. #12813
    include puppet::hack
  }

  if $manage_agent == true {

    # ----
    # Puppet agent management
    service { "puppet_agent":
      name       => $agent_service,
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }

    class { "puppet::monitor": enable => true; }

    # ----
    # Special things for special kernels
    case $kernel {
      linux: {
        file { $puppet::params::agent_defaults:
          mode   => '0644',
          owner  => 'root',
          group  => 'root',
          source => "puppet:///modules/puppet/${puppet::params::agent_defaults}",
        }
      }
      darwin: {
        file { "com.puppetlabs.puppet.plist":
          owner   => root,
          group   => 0,
          mode    => 0640,
          source  => "puppet:///modules/puppet/com.puppetlabs.puppet.plist",
          path    => "/Library/LaunchDaemons/com.puppetlabs.puppet.plist",
        }
      }
    }

  } else {

    # ----
    # Run the puppet agent out of cron at a random minute, every hour
    cron {
      "puppet agent":
        command => "${puppet_cmd} agent --onetime --no-daemonize >/dev/null",
        minute  => fqdn_rand( 60 ),
    }
    class { "puppet::monitor": enable => false; }
  }

  # ----
  # puppet.conf management
  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => $puppet_conf,
    content => template("puppet/puppet.conf-common.erb");
  }

  concat { $puppet::params::puppet_conf:
    mode => '0644',
    gnu  => $kernel ? {
      'SunOS' => 'false',
      default => 'true',
    }
  }

}

