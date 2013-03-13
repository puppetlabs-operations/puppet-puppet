class puppet::agent::service (
  $start_on_boot = true
) {
  include puppet::params
  # ----
  # Puppet agent management
  service { "puppet_agent":
    name       => $puppet::params::agent_service,
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  class { "::puppet::agent::monitor": enable => true; }

  # ----
  # Special things for special kernels
  case $kernel {
    linux: {
      file { $puppet::params::agent_defaults:
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("puppet${puppet::params::agent_defaults}.erb"),
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
}
