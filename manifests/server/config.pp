class puppet::server::config {

  include puppet
  include puppet::params

  Ini_setting {
    path    => $puppet::params::puppet_conf,
    ensure  => 'present',
    section => 'master',
  }

  if $puppet::server::directoryenvs == true or $puppet::server::directoryenvs == 'true' {
    validate_string($puppet::server::environmentpath)
    validate_string($puppet::server::basemodulepath)
    validate_string($puppet::server::default_manifest)

    $env_ensure              = 'present'
    $basemod_ensure          = 'present'
    $default_manifest_ensure = 'present'

    # Remove deprecated settings
    $mod_ensure            = 'absent'
  } else {
    $env_ensure              = 'absent'
    $basemod_ensure          = 'absent'
    $default_manifest_ensure = 'absent'

    # Leave deprecated settings in place
    $mod_ensure            = 'present'
  }

  ini_setting {
    'environmentpath':
      ensure  => $env_ensure,
      section => 'main',
      setting => 'environmentpath',
      value   => $puppet::server::environmentpath;

    'basemodulepath':
      ensure  => $basemod_ensure,
      section => 'main',
      setting => 'basemodulepath',
      value   => $puppet::server::basemodulepath;

    'default_manifest':
      ensure  => $default_manifest_ensure,
      section => 'main',
      setting => 'default_manifest',
      value   => $puppet::server::default_manifest;

    'modulepath':
      ensure  => $mod_ensure,
      setting => 'modulepath',
      value   => join($puppet::server::modulepath, ':');

    'manifest':
      ensure  => $mod_ensure,
      setting => 'manifest',
      value   => $puppet::server::manifest;

    'user':
      setting => 'user',
      value   => 'puppet';
    'group':
      setting => 'group',
      value   => 'puppet';

    'stringify_facts_master':
      setting => 'stringify_facts',
      section => 'main',
      value   => $puppet::server::stringify_facts;
  }

  ini_setting { 'ca':
    setting => 'ca',
    value   => $puppet::server::ca,
  }

  if $puppet::server::servertype == 'standalone' {
    ini_setting { 'bindaddress':
      setting => 'bindaddress',
      value   => $puppet::server::bindaddress,
    }
  }

  if $puppet::server::config_version_cmd {
    ini_setting { 'config_version':
      ensure  => $mod_ensure,
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
    }
  }

  if $puppet::server::reportfrom {
    ini_setting {
      'reportfrom':
        setting => 'reportfrom',
        value   => $puppet::server::reportfrom;
    }
  }

  unless empty($puppet::server::reports) {
    ini_setting { 'reports':
      setting => 'reports',
      value   => join(flatten([ $puppet::server::reports ]), ', '),
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

  if $puppet::server::dns_alt_names {
    ini_setting { 'dns_alt_names':
        setting => 'dns_alt_names',
        value   =>  $puppet::server::dns_alt_names
    }
  }

  if $puppet::server::autosign {
    ini_setting { 'autosign':
        setting => 'autosign',
        value   =>  $puppet::server::autosign
    }
  }

}
