class puppet::storeconfig::postgresql (
    $dbuser,
    $dbpassword
  ){

  include puppet::params

  # ---
  # Install the pg gem
  package { 'pg':
    name => $operatingsystem ? {
      FreeBSD => "databases/rubygem-pg",
      default   => "pg",
    },
    provider => $operatingsystem ? {
      FreeBSD   => undef,
      default   => gem,
    },
    ensure => installed,
  }

  # ---
  # Database setup -- Something we don't have for Postgresql

}
