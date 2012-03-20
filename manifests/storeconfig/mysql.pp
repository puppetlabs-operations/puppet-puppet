class puppet::storeconfig::mysql (
    $dbuser,
    $dbpassword
  ){

  include puppet::params

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
