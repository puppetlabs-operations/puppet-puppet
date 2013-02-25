# Class: puppet::dashboard
#
# This class installs and configures parameters for Puppet Dashboard
#
# Parameters:
# * site: fqdn for the dashboard site
# * db_user: the username for the database
# * db_pw: the password for the database
# * allowip: space seperated list of ip addresses to allow report uploads
#
# Actions:
#   Install puppet-dashboard packages
#   Write the database.yml
#   Install the apache vhost
#   Installs logrotate
#
# Requires:
#
# Sample Usage:
#   class { puppet::dashboard: site => 'dashboard.xyz.net; }
#
class puppet::dashboard (
  $db_user,
  $db_pw,
  $db_host   = 'localhost',
  $db_name   = 'puppet_dashboard',
  $manage_db = true,
  $site      = "dashboard.${domain}",
  $allowip   = ''
) {

  include ruby::dev

  $allow_all_ips  = "${allowip},${ipaddress}"
  $approot        = '/usr/share/puppet-dashboard'
  $dashboard_site = $site

  unicorn::app { $dashboard_site:
    approot     => $approot,
    config_file => "${approot}/config/unicorn.config.rb",
    pidfile     => '/var/run/puppet/puppet_dashboard_unicorn.pid',
    socket      => '/var/run/puppet/puppet_dashboard_unicorn.sock',
    user        => 'www-data',
    group       => 'www-data',
  }

  nginx::unicorn { 'dashboard.puppetlabs.com':
    priority       => 50,
    unicorn_socket => '/var/run/puppet/puppet_dashboard_unicorn.sock',
    path           => $approot,
    auth           => {
      'auth'      => true,
      'auth_file' => '/etc/nginx/htpasswd',
      'allowfrom' => $allow_all_ips,
    },
    ssl            => true,
    sslonly        => true,
    isdefaultvhost => true, # default for SSL.
  }

  package { 'puppet-dashboard':
    ensure => present,
  }

  if $manage_db {
    # FIXME THIS IS NOT COMPATIBLE WITH THE NEW MYSQL MODULE
    mysql::db { "dashboard_production":
      db_user => $db_user,
      db_pw   => $db_pw;
    }
  }

  file { "${approot}/config.ru":
    ensure => present,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0644',
    source => 'puppet:///modules/unicorn/config.ru',
  }

  file { '/etc/puppet-dashboard/database.yml':
    ensure  => present,
    content => template('puppet/dashboard/database.yml.erb'),
    require => Package['puppet-dashboard'],
  }

  file { '/usr/share/puppet-dashboard/config/settings.yml':
    mode    => '0444',
    owner   => 'www-data',
    group   => 'www-data',
    content => "---\ntime_zone: 'Pacific Time (US & Canada)'",
    notify  => Unicorn::App[$dashboard_site],
  }

  file { [
      "${approot}/public",
      "${approot}/public/stylesheets",
      "${approot}/public/javascript"
  ]:
    mode => 0755,
    owner => 'www-data',
    group => 'www-data',
    require => Package['puppet-dashboard'],
  }
}
