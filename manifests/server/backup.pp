class puppet::server::backup {
  bacula::job {
    "${fqdn}-puppetmaster":
      files   => ["/etc/puppet","/var/lib/puppet"],
      exclude => ["/var/lib/puppet/reports"]
  }
}

