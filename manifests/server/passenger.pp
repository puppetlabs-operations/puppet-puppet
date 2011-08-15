class puppet::server::passenger {
  if $kernel != "Darwin" {
    include puppet::passenger
  }
}
