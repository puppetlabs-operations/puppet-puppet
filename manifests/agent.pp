class puppet::agent(
  $server,
  $ca_server      = $puppet::agent::server,
  $report_server  = $puppet::agent::server,
  $manage_service = undef,
  $method         = 'cron',
) {

  include puppet
  require puppet::package

  case $method {
    cron:    { class { 'puppet::agent::cron': manage_service => $manage_service } }
    service: { include puppet::agent::service }
    default: {
      notify { "Agent run method \"${method}\" is not supported by ${module_name}, defaulting to cron": loglevel => warning }
      class { 'puppet::agent::cron': manage_service => $manage_service }
    }
  }

  # ----
  # puppet.conf management
  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => $puppet::params::puppet_conf,
    content => template("puppet/puppet.conf/common.erb");
  }

}
