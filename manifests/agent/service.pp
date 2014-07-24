# Class: puppet::agent::service
#
# Manages enabling and disabling the Puppet agent service
#
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
  service { 'puppet_agent':
    ensure     => $ensure,
    name       => $puppet::params::agent_service,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }

  # ----
  # Special things for special kernels
  case $::kernel {
    darwin: {
      file { 'com.puppetlabs.puppet.plist':
        owner   => 'root',
        group   => '0',
        mode    => '0640',
        source  => 'puppet:///modules/puppet/com.puppetlabs.puppet.plist',
        path    => '/Library/LaunchDaemons/com.puppetlabs.puppet.plist',
      }
    }
    default: {

      if $puppet::params::agent_service_conf {
        $file_ensure = $puppet::params::agent_service_conf ? {
          undef   => 'absent',
          default => 'present',
        }

        file { 'puppet_agent_service_conf':
          ensure  => $file_ensure,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          content => template('puppet/agent_service.erb'),
          path    => $puppet::params::agent_service_conf,
        }
      }
    }
  }
}
