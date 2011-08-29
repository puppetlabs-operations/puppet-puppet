class puppet::monitor (
    $enable = true
  ) {

  if $enable == true {
    $ensure = "present"
  } else {
    $ensure = "absent"
  }

  if defined(Class["nagios"]) {
    include nagios::params

    notice ($::nagios::params::nagios_service)

    @@nagios_service { "check_puppetd_${hostname}":
      ensure    => $ensure,
      use       => 'generic-service',
      host_name => "$fqdn",
      check_command => $puppetversion ? {
        '0.25.4' => 'check_nrpe!check_proc!1:1 puppetd',
        default  => $operatingsystem ? {
          CentOS  => 'check_nrpe!check_proc!1:1 puppetd',
          default => 'check_nrpe!check_proc!1:1 puppet',
        },
      },
      service_description => "check_puppetd_${hostname}",
      target              => '/etc/nagios3/conf.d/nagios_service.cfg',
      notify              => Service[$::nagios::params::nagios_service],
    }
  }

}

