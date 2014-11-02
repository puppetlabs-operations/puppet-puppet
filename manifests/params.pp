# Default puppet data
class puppet::params {

  case $::operatingsystem {
    'debian', 'ubuntu': {
      $puppet_cmd                  = '/usr/bin/puppet'
      $agent_package               = 'puppet'
      $agent_service               = 'puppet'
      $agent_service_conf          = '/etc/default/puppet'
      $server_service_conf         = '/etc/default/puppetserver'
      $master_package              = 'puppetmaster'
      $master_service              = 'puppetmaster'
      $server_package              = 'puppetserver'
      $server_service              = 'puppetserver'
      $puppetserver_bootstrap_conf = '/etc/puppetserver/bootstrap.cfg'
      $puppet_conf                 = '/etc/puppet/puppet.conf'
      $puppet_confdir              = '/etc/puppet'
      $puppet_logdir               = '/var/log/puppet'
      $puppet_vardir               = '/var/lib/puppet'
      $puppet_ssldir               = '/var/lib/puppet/ssl'
      $puppet_rundir               = '/var/run/puppet'
      $default_method              = 'cron'
    }
    'freebsd': {
      $puppet_cmd         = '/usr/local/bin/puppet'
      $agent_package      = 'puppet'
      $agent_service      = 'puppet'
      $master_package     = 'puppet'
      $master_service     = 'puppetmaster'
      $server_package     = 'puppetserver'
      $server_service     = 'puppetserver'
      $puppet_conf        = '/usr/local/etc/puppet/puppet.conf'
      $puppet_confdir     = '/usr/local/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/puppet'
      $puppet_ssldir      = '/var/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
      $default_method     = 'cron'
    }
    'darwin': {
      $puppet_cmd     = '/opt/local/bin/puppet'
      $agent_package  = 'puppet'
      $agent_service  = 'com.puppetlabs.puppet'
      $master_package = ''
      $master_service = ''
      $puppet_conf    = '/etc/puppet/puppet.conf'
      $puppet_confdir = '/etc/puppet'
      $puppet_logdir  = '/var/log/puppet'
      $puppet_vardir  = '/var/lib/puppet'
      $puppet_ssldir  = '/etc/puppet/ssl'
      $puppet_rundir  = '/var/run'
      $default_method = 'cron'
    }
    'centos', 'redhat', 'fedora', 'sles', 'opensuse', 'OracleLinux': {
      $puppet_cmd                  = '/usr/bin/puppet'
      $agent_package               = 'puppet'
      $agent_service               = 'puppet'
      $agent_service_conf          = '/etc/sysconfig/puppet'
      $server_service_conf         = '/etc/sysconfig/puppetserver'
      $master_package              = 'puppet-server'
      $master_service              = 'puppetmaster'
      $server_package              = 'puppetserver'
      $server_service              = 'puppetserver'
      $puppetserver_bootstrap_conf = '/etc/puppetserver/bootstrap.cfg'
      $puppet_conf                 = '/etc/puppet/puppet.conf'
      $puppet_confdir              = '/etc/puppet'
      $puppet_logdir               = '/var/log/puppet'
      $puppet_vardir               = '/var/lib/puppet'
      $puppet_ssldir               = '/var/lib/puppet/ssl'
      $puppet_rundir               = '/var/run/puppet'
      $default_method              = 'cron'
    }
    'gentoo': {
      $puppet_cmd         = '/usr/bin/puppet'
      $agent_package      = 'app-admin/puppet'
      $agent_service      = 'puppet'
      $agent_use          = ['minimal']
      $master_package     = 'app-admin/puppet'
      $master_service     = 'puppetmaster'
      $server_package     = 'puppetserver'
      $server_service     = 'puppetserver'
      $master_use         = ['-minimal']
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/lib/puppet'
      $puppet_ssldir      = '/var/lib/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
      $default_method     = 'cron'
    }
    'openbsd': {
      $puppet_cmd         = '/usr/local/bin/puppet'
      $agent_package      = 'puppet'
      $agent_service      = 'puppetd'
      $master_package     = 'puppet'
      $master_service     = 'puppetmasterd'
      $server_package     = 'puppetserver' # See https://tickets.puppetlabs.com/browse/SERVER-14 for OpenBSD puppetserver status
      $server_service     = 'puppetserver'
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/puppet/log'
      $puppet_vardir      = '/var/puppet'
      $puppet_ssldir      = '/etc/puppet/ssl'
      $puppet_rundir      = '/var/puppet/run'
      $default_method     = 'service'
    }
    # This stops the puppet class breaking. But really, we only have very
    # limited support for Solaris. And only through OpenCSW
    # Taken from: '/opt/csw/bin/puppet config print ...'
    'solaris','sunos': {
      $puppet_cmd         = '/opt/csw/bin/puppet'
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/lib/puppet'
      $puppet_ssldir      = '/etc/puppet/ssl'
      $puppet_rundir      = '/var/lib/puppet/run/'
      $agent_service      = 'svc:/network/cswpuppetd'
      $default_method     = 'cron'
    }
    'windows': {
      $puppet_cmd         = 'C:/Program Files (x86)/Puppet Labs/Puppet/bin/puppet.bat'
      $agent_package      = 'Puppet'
      $agent_service      = 'puppet'
      # I don't think these are applicable to Windows
      # $agent_service_conf = '/etc/default/puppet'
      # $master_package     = 'puppetmaster'
      # $master_service     = 'puppetmaster'

      # Note this is only going to work for 2008 and later
      # The correct value is %APPDATA% (or something similar)
      $puppet_conf        = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
      $puppet_confdir     = 'C:/ProgramData/PuppetLabs/puppet/etc'
      $puppet_logdir      = 'C:/ProgramData/PuppetLabs/puppet/var/log'
      $puppet_vardir      = 'C:/ProgramData/PuppetLabs/puppet/var'
      $puppet_ssldir      = 'C:/ProgramData/PuppetLabs/puppet/etc/ssl'
      $puppet_rundir      = 'C:/ProgramData/PuppetLabs/puppet/var/run'
      $default_method     = 'only_service'
    }
    default: { fail("Sorry, ${::operatingsystem} is not supported") }
  }

  $puppet_user = $::osfamily ? {
    'OpenBSD' => '_puppet',
    default   => 'puppet',
  }

  $puppet_group = $::osfamily ? {
    'OpenBSD' => '_puppet',
    default   => 'puppet',
  }
}
