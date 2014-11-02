# puppet::server::puppetserver configures the master using the new JVM puppet server
# Puppet Server is pre-release and not recommended for production use yet
# See https://github.com/puppetlabs/puppet-server/blob/master/documentation/install_from_packages.markdown for basic
# manual install documentation

# This class should not normally be used directly.

# TODO: Add support for external SSL termination
# https://github.com/puppetlabs/puppet-server/blob/master/documentation/external_ssl_termination.markdown

# TODO: Add ability to configure stuff from:
# https://github.com/puppetlabs/puppet-server/blob/master/documentation/configuration.markdown
# - where JRuby will look for gems
# - path to puppet conf dir
# - path to puppet var dir
# - maximum number of JRuby instances to allow; defaults to <num-cpus>+2
# - enable/disable the CA service via trapperkeeper settings
# - configure logging via logback

# Note that OpenBSD support is blocking on https://tickets.puppetlabs.com/browse/SERVER-14

# parameters
# descriptions largely copied from official docs at
# https://github.com/puppetlabs/puppet-server/blob/master/documentation/configuration.markdown
# [*memory*]                - (optional) set JVM memory use; 2gb recommended by default
#                             format is "2gb", "512m", etc.
# [*max_active_instances*]  - (optional) maximum number of JRuby instances to allow
# [*logging_config*]        - (optional) Path to logback logging configuration file
#                             http://logback.qos.ch/manual/configuration.html
# [*gem_home*]              - (optional) determines where JRuby will look for gems. Also
#                             used by the `puppetserver gem` command line tool.
# [*master_conf_dir*]       - (optional) path to puppet conf dir
# [*master_var_dir*]        - (optional) path to puppet var dir
# [*enable_profiler*]       - (optional) enable or disable profiling for the Ruby code
#      (true|false)
# [*allow_header_cert_info  - (optional) Allows the "ssl_client_header" and
#      (true|false)           "ssl_client_verify_header" options set in
#                             puppet.conf to work. These headers will be
#                             ignored unless "allow-header-cert-info" is true

# puppetserver.conf is in HOCON format, which is a superset of JSON:
# - https://github.com/puppetlabs/puppet-server/blob/master/documentation/configuration.markdown
# - https://github.com/typesafehub/config#using-hocon-the-json-superset
# puppet-puppet will simply create pure JSON puppetserver.conf files because
# it's way easier to work with, until we get a proper augeas provider

class puppet::server::puppetserver (
  # aside from memory (defaults to 2g), these are the puppetserver defaults
  # Setting them here makes it easier to anticipate behavior
  $enabled                = true,
  $memory_pct             = 70,
  $memory                 = undef,
  $max_active_instances   = $::processorcount + 2,
  $logging_config         = '/etc/puppetserver/logback.xml',
  $gem_home               = '/var/lib/puppet/jruby-gems',
  $master_conf_dir        = '/etc/puppet',
  $master_var_dir         = '/var/lib/puppet',
  $enable_profiler        = false,
  $allow_header_cert_info = false,
  $bootstrap_cfg          = '/etc/puppetserver/bootstrap.cfg'
) {

  include puppet
  include puppet::server

  # Calculate JVM memory based on percentage if specified
  if ($memory_pct != undef) and ($memory != undef) {
    fail('memory and memory_pct cannot both be set at the same time')
  }
  if ($memory_pct != undef) and ($memory == undef) {
    $rounded_mem = floor($::memorysize_mb * $memory_pct * 0.01)
    $jvm_memory = "${rounded_mem}m"
  }
  if ($memory_pct == undef) and ($memory != undef) {
    $jvm_memory = $memory
  }

  $service_ensure = $enabled? {
    true    => 'running',
    default => 'stopped',
  }

  Ini_subsetting {
    ensure            => present,
    section           => '',
    key_val_separator => '=',
    path              => $puppet::params::server_service_conf,
    setting           => 'JAVA_ARGS',
    notify            => Service[$puppet::params::server_service],
  }

  ini_subsetting {'puppetserver_xmx_memory':
    subsetting        => '-Xmx',
    value             => $jvm_memory,
  }
  ini_subsetting {'puppetserver_xms_memory':
    subsetting        => '-Xms',
    value             => $jvm_memory,
  }

  # disable the trapperkeeper-based CA service entirely if this isn't a CA node
  $ca_disable_ensure = $puppet::params::ca? {
    false   => 'present',
    default => 'absent',
  }
  $ca_enable_ensure = $puppet::params::ca? {
    false   => 'absent',
    default => 'present',
  }
  file_line { 'disable_puppetserver_ca':
    ensure  => $ca_disable_ensure,
    path    => $puppet::params::puppetserver_bootstrap_conf,
    line    => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
    require => Package[$puppet::params::server_package],
  }
  file_line { 'enable_puppetserver_ca':
    ensure  => $ca_enable_ensure,
    path    => $puppet::params::puppetserver_bootstrap_conf,
    line    => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
    require => Package[$puppet::params::server_package],
  }

  service { $puppet::params::server_service:
    ensure    => $service_ensure,
    enable    => $enabled,
    hasstatus => true,
    require   => [Class['puppet::server::config'],
                  Class['puppet::server::standalone'],
                  Package[$puppet::params::server_package]],
  }

  # stop regular puppet master to avoid conflicting binds on port 8140
  if $enabled == true {
    package { $puppet::params::server_package:
      ensure => $puppet::server::ensure;
    }
    class { 'puppet::server::standalone':
      enabled => false
    }
  }
}
