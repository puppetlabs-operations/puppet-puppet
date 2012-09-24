class puppet::server::standalone($enabled = true) {

  include puppet
  include puppet::server

  motd::register{ 'Puppet Master on webbrick': }

  service { $puppet::params::master_service:
    ensure    => $enabled ? {true => running, false => stopped},
    enable    => $enabled,
    hasstatus => true,
    require   => File[$puppet::params::puppet_conf];
  }
}
