class puppet::storeconfig::postgresql (
    $dbuser,
    $dbpassword
  ){

  include puppet::params

  # ---
  # PostgreSQL backend settings
  Ini_setting {
    ensure  => 'present',
    section => 'master',
    path    => $puppet::params::puppet_conf,
  }

  ini_setting {
    'dbadapter':
      setting => 'dbadapter',
      value   => 'postgresql';
    'dbmigrate':
      setting => 'dbmigrate',
      value   => 'true';
    'dbuser':
      setting => 'dbuser',
      value   => $dbuser;
    'dbpassword':
      setting => 'dbpassword',
      value   => $dbpassword;
    'dbserver':
      setting => 'dbserver',
      value   => $puppet::storeconfig::dbserver;
    'dbname':
      setting => 'dbname',
      value   => 'puppet';
  }

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
