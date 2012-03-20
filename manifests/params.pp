class puppet::params {

  # ---
  # Yup, its a params class.
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
      $unicorn_initscript = 'unicorn/initscript_newer.erb'
    }
    'freebsd': {
      $puppet_cmd         = '/usr/local/bin/puppet'
      $agent_service      = 'puppet'
      $master_package     = ''
      $master_service     = ''
      $puppet_conf        = '/usr/local/etc/puppet/puppet.conf'
      $puppet_confdir     = '/usr/local/etc/puppet'
      $puppet_logdir      = '/var/log/puppet'
      $puppet_vardir      = '/var/puppet'
      $puppet_ssldir      = '/var/puppet/ssl'
      $puppet_rundir      = '/var/run/puppet'
      $unicorn_initscript = 'unicorn/rcscript.erb'
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
      $unicorn_initscript = 'unicorn/initscript_newer.erb'
    }
  }

  # Behold, the list of platforms that have horrible package mangement!
  if $kernel == 'Darwin' or $kernel == 'SunOS' or $kernel == 'FreeBSD' or $operatingsystem == 'SLES' {
    $update_puppet = undef
  }
  else {
    $update_puppet = true
  }

}
