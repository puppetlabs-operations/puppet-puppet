class puppet::server::config {

  include puppet
  include puppet::params

  Ini_setting {
    path    => $puppet::params::puppet_conf,
    ensure  => 'present',
    section => 'master',
  }

  ini_setting {
    'modulepath':
      setting => 'modulepath',
      value   => join($puppet::server::modulepath, ':');
    'manifest':
      setting => 'manifest',
      value   => $puppet::server::manifest;
    'user':
      setting => 'user',
      value   => 'puppet';
    'group':
      setting => 'group',
      value   => 'puppet';
  }

  if $puppet::server::ca {
    ini_setting { 'ca':
      setting => 'ca',
      value   => $puppet::server::ca,
    }
  }

  if $puppet::server::servertype == 'standalone' {
    ini_setting { 'bindaddress':
      setting => 'bindaddress',
      value   => $puppet::server::bindaddress,
    }
  }

  if $puppet::server::config_version_cmd {
    ini_setting { 'config_version':
      setting => 'config_version',
      value   => $puppet::server::config_version_cmd,
    }
  }

  if $puppet::server::ssl_client_header {
    ini_setting {
      'ssl_client_header':
        setting => 'ssl_client_header',
        value   => $puppet::server::ssl_client_header;
      'ssl_client_verify_header':
        setting => 'ssl_client_verify_header',
        value   => $puppet::server::ssl_client_verify_header;
    }
  }

  if $puppet::server::report {
    ini_setting {
      'master_report':
        setting => 'report',
        value   => $puppet::server::report;
      'reporturl':
        setting => 'reporturl',
        value   => $puppet::server::reporturl;
      'reporturl_ssl_verify':
        setting => 'reporturl_ssl_verify',
        value   => 'true';
      'reporturl_ssl_cert':
        setting => 'reporturl_ssl_cert',
        value   => '/etc/ssl/certs/ca-certificates.crt';
      'reportfrom':
        setting => 'reportfrom',
        value   => $puppet::server::reportfrom;
    }
  }

  unless empty($puppet::server::reports) {
    if is_array($puppet::server::reports) {
      ini_setting { 'reports':
        setting => 'reports',
        value   => join($puppet::server::reports, ", "),
      }
    } else {
      ini_setting { 'reports':
        setting => 'reports',
        value   => $puppet::server::reports,
      }
    }
  }

  if $puppet::server::enc == 'exec' {
    ini_setting {
      'node_terminus':
        setting => 'node_terminus',
        value   => 'exec';
      'external_nodes':
        setting => 'external_nodes',
        value   => $puppet::server::enc_exec;
    }
  }

  if $puppet::server::parser {
    ini_setting { 'parser':
        setting => 'parser',
        value   => $puppet::server::parser,
    }
  }

}
