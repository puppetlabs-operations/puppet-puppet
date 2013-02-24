class puppet::package {

  include puppet::package::repository

  # Fixes a bug. #12813
  class { '::puppet::package::patches': }
}
