# Default puppet data
class puppet::params::defaults {

  case $operatingsystem {
    'debian', 'ubuntu': {
      $puppet_cmd         = '/usr/bin/puppet'
      $agent_service      = 'puppet'
      $agent_defaults     = '/etc/default/puppet'
      $master_package     = 'puppetmaster'
      $master_service     = 'puppetmaster'
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/lib/puppet'
      $puppet_ssldir      = '/var/lib/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
    }
    'freebsd': {
      $puppet_cmd         = '/usr/local/bin/puppet'
      $agent_service      = 'puppet'
      $master_package     = ''
      $master_service     = 'puppetmaster'
      $puppet_conf        = '/usr/local/etc/puppet/puppet.conf'
      $puppet_confdir     = '/usr/local/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/puppet'
      $puppet_ssldir      = '/var/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
    }
    'darwin': {
      $puppet_cmd     = '/opt/local/bin/puppet'
      $agent_service  = 'com.puppetlabs.puppet'
      $master_package = ''
      $master_service = ''
      $puppet_conf    = '/etc/puppet/puppet.conf'
      $puppet_confdir = '/etc/puppet'
      $puppet_logdir  = '/var/log/puppet'
      $puppet_vardir  = '/var/lib/puppet'
      $puppet_ssldir  = '/etc/puppet/ssl'
      $puppet_rundir  = '/var/run'
    }
   'centos', 'redhat', 'fedora', 'sles': {
      $puppet_cmd         = '/usr/bin/puppet'
      $agent_service      = 'puppet'
      $agent_defaults     = '/etc/sysconfig/puppet'
      $master_package     = 'puppet-server'
      $master_service     = 'puppetmasterd'
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/lib/puppet'
      $puppet_ssldir      = '/var/lib/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
    }
    'gentoo': {
      $puppet_cmd         = '/usr/bin/puppet'
      $agent_service      = 'puppet'
      $master_package     = 'app-admin/puppet'
      $master_service     = 'puppetmaster'
      $puppet_conf        = '/etc/puppet/puppet.conf'
      $puppet_confdir     = '/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/lib/puppet'
      $puppet_ssldir      = '/var/lib/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
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
    }
    default: { fail("Sorry, $operatingsystem is not supported") }
  }

  # Behold, the list of platforms that have horrible package mangement!
  if $kernel == 'Darwin' or $kernel == 'SunOS' or $kernel == 'FreeBSD' or $operatingsystem == 'SLES' {
    $update_puppet = undef
  }
  else {
    # FIXME
    # http://projects.puppetlabs.com/issues/10590
    # err: Could not retrieve catalog from remote server: Error 400 on SERVER: can't clone TrueClass
    #
    # Use a real boolean after hiera 1.0 is out
    $update_puppet = 'true'
  }
}
