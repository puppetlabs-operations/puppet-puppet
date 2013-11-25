class puppet::server::passenger {

  class { 'puppet::server::standalone': enabled => false }

  if $kernel != "Darwin" {
    include puppet::passenger
  }
}
