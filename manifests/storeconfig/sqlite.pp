class puppet::storeconfig::sqlite {

  include puppet::params

  Ini_setting {
    ensure  => 'present',
    section => 'master',
    path    => $puppet::params::puppet_conf,
  }

  ini_setting {
    'dbadapter':
      setting => 'dbadapter',
      value   => 'sqlite3';
    'dbmigrate':
      setting => 'dbmigrate',
      value   => 'true';
  }

  # ---
  # Seems like this should install a gem or something useful

}
