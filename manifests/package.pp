class puppet::package (
  $agent_package  = $puppet::params::agent_package,
  $master_package = $puppet::params::master_package,
) inherits puppet::params {

  $packages = union([$agent_package], [$master_package])
  @package { $packages: }

  include puppet::params

  if $puppet::agent::manage_repos {
    include puppet::package::repository
  }

  if $::operatingsystem == 'gentoo' {
    include puppet::package::gentoo
  }
}
