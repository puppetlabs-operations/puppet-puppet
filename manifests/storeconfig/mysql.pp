class puppet::storeconfig::mysql (
    $dbuser,
    $dbpassword
  ){

  include puppet::params

  # ---
  # MySQL backend settings
  Ini_setting {
    ensure  => 'present',
    section => 'master',
    path    => $puppet::params::puppet_conf,
  }

  ini_setting {
    'dbadapter':
      setting => 'dbadapter',
      value   => 'mysql';
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
    'dbsocket':
      setting => 'dbsocket',
      value   => $puppet::storeconfig::dbsocket;
  }

  # ---
  # Install the mysql gem
  package { "gem-mysql":
    name => $operatingsystem ? {
      "Debian" => "libmysql-ruby",
      "Darwin" => "rb-mysql",
      default  => mysql,
    },
    provider => $operatingsystem ? {
      "Debian" => apt,
      "Darwin" => macports,
      default  => gem,
    },
    ensure => installed,
  }

  # ---
  # Database setup
  database{ 'puppet':
    ensure  => present,
    charset => 'utf8',
  }

  database_user{"$dbuser@localhost":
    ensure        => present,
    password_hash => mysql_password($dbpassword),
    require       => Database['puppet'],
  }

  database_grant{ 'puppet@localhost/puppet':
    privileges => [all],
    require    => [ Database['puppet'], Database_user['puppet@localhost'] ],
  }
}
