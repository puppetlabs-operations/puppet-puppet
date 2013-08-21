class puppet::agent::monitor (
    $enable = true
) {

  $ensure = $enable ? {
    true    => "present",
    default => "absent"
  }

  if defined(Class["nagios"]) {
    include nagios::params

    @@nagios_service { "check_puppetd_${fqdn}":
      ensure         => $ensure,
      use            => 'generic-service',
      host_name      => "$fqdn",
      check_command => $puppetversion ? {
        '0.25.4' => 'check_nrpe!check_proc!1:1 puppetd',
        default  => $operatingsystem ? {
          CentOS  => 'check_nrpe!check_proc!1:1 puppetd',
          default => 'check_nrpe!check_proc!1:1 puppet',
        },
      },
      service_description => "check_puppetd_${fqdn}",
      target              => '/etc/nagios3/conf.d/nagios_service.cfg',
      notify              => Service[$::nagios::params::nagios_service],
    }

    @@nagios_servicedependency {"check_puppetd_${fqdn}":
      host_name                     => "$fqdn",
      service_description           => "check_ping_${fqdn}",
      dependent_host_name           => "$fqdn",
      dependent_service_description => "check_puppetd_${fqdn}",
      execution_failure_criteria    => "n",
      notification_failure_criteria => "w,u,c",
      ensure                        => present,
      target                        => '/etc/nagios3/conf.d/nagios_servicedep.cfg',
    }
  }

}
