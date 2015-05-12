class puppet::storeconfig::postgresql (
  $dbuser,
  $dbpassword
) {

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
      value   => true;
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
  $package_name = $::operatingsystem ? {
    'FreeBSD' => 'databases/rubygem-pg',
    default   => 'pg',
  }
  $package_provider  = $::operatingsystem ? {
    'FreeBSD' => undef,
    default   => gem,
  }
  package { 'pg':
    ensure   => installed,
    name     => $package_name,
    provider => $package_provider,
  }

  # ---
  # Database setup -- Something we don't have for Postgresql

}
