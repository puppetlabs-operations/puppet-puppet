# Class: puppet
#
# This class installs and configures Puppet
#
# Parameters:
#
# Actions:
# - Install Puppet
#
# Requires:
#
# Sample Usage:
#
class puppet ($server){
  include ruby
  include puppet::params

  $puppet_server = $server
  $puppet_storedconfig_password = $puppet::params::puppet_storedconfig_password
  $puppetd_service = $puppet::params::puppetd_service

  package { 'puppet':
    ensure => installed,
  }

  file { $puppet::params::puppetd_defaults:
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => "puppet:///modules/puppet/${puppet::params::puppetd_defaults}",
  }
  service { "puppetd":
    name       => "$puppetd_service",
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

#  file { '/etc/puppet/puppet.conf':
#    content => $fqdn ? {
#      $puppet_server => template('puppet/puppet-server.conf.erb'),
#      default => template('puppet/puppet.conf.erb'),
#    },
#    notify => Service["puppetd"],
#    require => Package['puppet'],
#  }

  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-common.erb");
  }

  concat { "/etc/puppet/puppet.conf":
    mode    => '0644',
    notify  => Service["puppetd"],
    require => Package['puppet'];
  }

}

