class puppet::server::monitor (
  $ca = true 
) {
  @@nagios_service { "check_puppetmaster_${::hostname}":
    use                 => 'generic-service',
    check_command       => 'check_puppetmaster',
    host_name           => $::fqdn,
    service_description => "check_puppetmaster_${::hostname}",
    target              => '/etc/nagios3/conf.d/nagios_service.cfg',
    notify              => Service[nagios::params::nagios_service],
  }

  @@nagios_servicedependency {"check_puppetmaster_${::hostname}":
    host_name                     => "$::fqdn",
    service_description           => "check_ping_${::hostname}",
    dependent_host_name           => "$::fqdn",
    dependent_service_description => "check_puppetmaster_${::hostname}",
    execution_failure_criteria    => "n",
    notification_failure_criteria => "w,u,c",
    ensure                        => present,
    target                        => '/etc/nagios3/conf.d/nagios_servicedep.cfg',
  }

  if $ca == true {
    @@nagios_service { "check_certs_${::hostname}":
      use                 => 'generic-service',
      check_command       => 'check_nrpe_1arg!check_certs',
      host_name           => $::fqdn,
      service_description => "check_certs_${::hostname}",
      target              => '/etc/nagios3/conf.d/nagios_service.cfg',
      notify              => Service[nagios::params::nagios_service],
    }

    @@nagios_servicedependency {"check_certs_${::hostname}":
      host_name                     => "$::fqdn",
      service_description           => "check_ping_${::hostname}",
      dependent_host_name           => "$fqdn",
      dependent_service_description => "check_certs_${::hostname}",
      execution_failure_criteria    => "n",
      notification_failure_criteria => "w,u,c",
      ensure                        => present,
      target                        => '/etc/nagios3/conf.d/nagios_servicedep.cfg',
    }
  }
}

