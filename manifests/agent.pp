class puppet::agent($method = 'cron') {

  # This could be
  #
  #    require 'puppet::package'
  #
  # yep.
  include puppet::package
  Class['puppet::package'] -> Class['puppet::agent']

  case $method {
    cron:    { include puppet::agent::cron }
    service: { include puppet::agent::service }
    default: { fail("Method ${method} is not supported by ${module}") }
  }
}
