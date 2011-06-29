class puppet::server::backup {
  bacula::job {
    "${fqdn}-puppetmaster":
      files    => ["/etc/puppet","/var/lib/puppet"],
      excludes => ["/var/lib/puppet/reports"]
  }
}

