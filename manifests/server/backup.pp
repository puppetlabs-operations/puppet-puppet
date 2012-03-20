class puppet::server::backup {

  include puppet::params

  if defined(Class["bacula"]) {
    bacula::job {
      "${fqdn}-puppetmaster":
        files    => [$puppet_confdir,$puppet_vardir],
        excludes => ["${puppet_vardir}/reports"]
    }
  }

}
