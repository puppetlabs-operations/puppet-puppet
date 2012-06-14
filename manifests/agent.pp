class puppet::agent($method = 'cron') {

  case $method {
    cron:    { include puppet::agent::cron }
    service: { include puppet::agent::service }
    default: { fail("Method ${method} is not supported by ${module}") }
  }
}
