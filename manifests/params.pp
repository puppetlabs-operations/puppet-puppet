# Default puppet data
class puppet::params {

  case $::operatingsystem {
    'debian', 'ubuntu': {
      $os_specific = {
        # placeholder
      }
    }
    'freebsd': {
      $os_specific = {
        puppet_cmd     => '/usr/local/bin/puppet',
        master_package => 'puppet',
        puppet_conf    => '/usr/local/etc/puppet/puppet.conf',
        puppet_confdir => '/usr/local/etc/puppet',
        puppet_logdir  => '/var/log/puppet',
        puppet_vardir  => '/var/puppet',
        puppet_ssldir  => '/var/puppet/ssl',
      }
    }
    'darwin': {
      $os_specific = {
        puppet_cmd     => '/usr/bin/puppet',
        agent_service  => 'com.puppetlabs.puppet',
        master_package => '',
        master_service => '',
        puppet_ssldir  => '/etc/puppet/ssl',
      }
    }
    'centos', 'redhat', 'fedora', 'sles', 'opensuse', 'OracleLinux': {
      $os_specific = {
        agent_service_conf => '/etc/sysconfig/puppet',
        master_package     => 'puppet-server',
      }
    }
    'gentoo': {
      $os_specific = {
        agent_package  => 'app-admin/puppet',
        master_package => 'app-admin/puppet',
      }
    }
    'openbsd': {
      $os_specific = {
        puppet_cmd         => '/usr/local/bin/puppet',
        agent_service      => 'puppetd',
        agent_service_conf => undef,
        master_package     => 'puppet',
        master_service     => 'puppetmasterd',
        puppet_logdir      => '/var/puppet/log',
        puppet_vardir      => '/var/puppet',
        puppet_ssldir      => '/etc/puppet/ssl',
        puppet_rundir      => '/var/puppet/run',
        default_method     => 'service',
        puppet_user        => '_puppet',
        puppet_group       => '_puppet',
      }
    }
    # This stops the puppet class breaking. But really, we only have very
    # limited support for Solaris. And only through OpenCSW
    # Taken from: '/opt/csw/bin/puppet config print ...'
    'solaris','sunos': {
      $os_specific = {
        puppet_cmd     => '/opt/csw/bin/puppet',
        puppet_ssldir  => '/etc/puppet/ssl',
        puppet_rundir  => '/var/lib/puppet/run/',
        agent_service  => 'svc:/network/cswpuppetd',
      }
    }
    'windows': {
      $os_specific = {
        puppet_cmd     => 'C:/Program Files (x86)/Puppet Labs/Puppet/bin/puppet.bat',
        agent_package  => 'Puppet',
        # Note this is only going to work for 2008 and later
        # The correct value is %APPDATA% (or something similar)
        puppet_conf    => 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf',
        puppet_confdir => 'C:/ProgramData/PuppetLabs/puppet/etc',
        puppet_logdir  => 'C:/ProgramData/PuppetLabs/puppet/var/log',
        puppet_vardir  => 'C:/ProgramData/PuppetLabs/puppet/var',
        puppet_ssldir  => 'C:/ProgramData/PuppetLabs/puppet/etc/ssl',
        puppet_rundir  => 'C:/ProgramData/PuppetLabs/puppet/var/run',
        default_method => 'only_service',
      }
    }
    default: { fail("Sorry, ${::operatingsystem} is not supported") }
  }

  $default_value = {
    agent_package      => 'puppet',
    agent_service      => 'puppet',
    agent_service_conf => '/etc/default/puppet',
    default_method     => 'cron',
    master_package     => 'puppetmaster',
    master_service     => 'puppetmaster',
    puppet_cmd         => '/usr/bin/puppet',
    puppet_conf        => '/etc/puppet/puppet.conf',
    puppet_confdir     => '/etc/puppet',
    puppet_logdir      => '/var/log/puppet',
    puppet_rundir      => '/var/run/puppet',
    puppet_ssldir      => '/var/lib/puppet/ssl',
    puppet_user        => 'puppet',
    puppet_group       => 'puppet',
    puppet_vardir      => '/var/lib/puppet',
    report_dir         => '/usr/lib/ruby/vendor_ruby/puppet/reports',
  }

  $merged_values = merge($default_value, $os_specific)

  $agent_package      = $merged_values[agent_package]
  $agent_service      = $merged_values[agent_service]
  $agent_service_conf = $merged_values[agent_service_conf]
  $agent_use          = $merged_values[agent_use]
  $default_method     = $merged_values[default_method]
  $master_package     = $merged_values[master_package]
  $master_service     = $merged_values[master_service]
  $master_use         = $merged_values[master_use]
  $puppet_cmd         = $merged_values[puppet_cmd]
  $puppet_conf        = $merged_values[puppet_conf]
  $puppet_confdir     = $merged_values[puppet_confdir]
  $puppet_group       = $merged_values[puppet_group]
  $puppet_logdir      = $merged_values[puppet_logdir]
  $puppet_rundir      = $merged_values[puppet_rundir]
  $puppet_ssldir      = $merged_values[puppet_ssldir]
  $puppet_user        = $merged_values[puppet_user]
  $puppet_vardir      = $merged_values[puppet_vardir]

}
