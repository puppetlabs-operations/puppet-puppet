class puppet::agent::service (
  $enable = true
) {
  include puppet::params

  if $enable {
    $ensure = running
  } else {
    $ensure = stopped
  }

  # ----
  # Puppet agent management
  service { "puppet_agent":
    name       => $puppet::params::agent_service,
    ensure     => $ensure,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  # ----
  # Special things for special kernels
  case $kernel {
    linux: {
      file { $puppet::params::agent_defaults:
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
        source => template("puppet:///modules/puppet/${puppet::params::agent_defaults}.erb"),
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
