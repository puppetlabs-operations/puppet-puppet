# == Class: puppet
#
# == Description
#
# This manifest provides for shared behavior and resources between the agent
# and master.
#
# This module should not be directly included.
#
class puppet {
  include puppet::params
  include concat::setup

  # ----
  # puppet.conf management
  concat::fragment { 'puppet.conf-agent':
    order   => '00',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/main.erb");
  }

  # ----
  # collect the puppet.conf fragments
  concat { $puppet::params::puppet_conf:
    mode => '0644',
    gnu  => $kernel ? {
      'SunOS' => 'false',
      default => 'true',
    }
  }
}
