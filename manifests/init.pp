# == Class: puppet
#
# == Description
#
# Sets up the /etc/puppet ownership and various puppet.conf variables under the
# [main] section
#
# This class should not be directly included. Its parameters should be defined
# in hieradata.
#
# == Parameters
#
# [*logdir*]
# The logdir variable in puppet.conf.
# Default: platform dependent
#
# [*vardir*]
# The vardir variable in puppet.conf.
# Default: platform dependent
#
# [*ssldir*]
# The ssldir variable in puppet.conf.
# Default: platform dependent
#
# [*rundir*]
# The rundir variable in puppet.conf.
# Default: platform dependent
#
# [*confdir*]
# The confdir variable in puppet.conf.
# Default: platform dependent
#
# [*user*]
# The owner of /etc/puppet directory
# Default: platform dependent
#
# [*group*]
# The group of /etc/puppet directory
# Default: platform dependent
#
# [*conf*]
# The path of the puppet.conf file
# Default: platform dependent
#
# [*use_srv_records*]
# The use_srv_records variable in puppet.conf.
# Default: false
#
# [*srv_domain*]
# The srv_domain variable in puppet.conf.
# Default: $::domain
#
class puppet (
  $logdir          = $puppet::params::puppet_logdir,
  $vardir          = $puppet::params::puppet_vardir,
  $ssldir          = $puppet::params::puppet_ssldir,
  $rundir          = $puppet::params::puppet_rundir,
  $confdir         = $puppet::params::puppet_confdir,
  $user            = $puppet::params::puppet_user,
  $group           = $puppet::params::puppet_group,
  $conf            = $puppet::params::puppet_conf,
  $use_srv_records = false,
  $srv_domain      = $::domain,
) inherits puppet::params {

  validate_bool($use_srv_records)

  include puppet::config

  file { $confdir:
    ensure => 'directory',
    owner  => $user,
    group  => $group,
  }
}
