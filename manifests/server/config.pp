# Private class
class puppet::server::config {

  include puppet

  Ini_setting {
    path    => $puppet::conf,
    ensure  => 'present',
    section => 'master',
    notify  => Service[$puppet::server::service],
  }

  if $puppet::server::directoryenvs == true {
    if $puppet::server::environmentpath {
      validate_string($puppet::server::environmentpath)
      $environmentpath_ensure = 'present'
    } else {
      $environmentpath_ensure = 'absent'
    }

    if $puppet::server::basemodulepath {
      $basemodulepath_ensure = 'present'
    } else {
      $basemodulepath_ensure = 'absent'
    }

    if $puppet::server::default_manifest {
      validate_string($puppet::server::default_manifest)
      $default_manifest_ensure = 'present'
    } else {
      $default_manifest_ensure = 'absent'
    }
    $manifest_ensure       = 'absent'
    $modulepath_ensure     = 'absent'
    $config_version_ensure = 'absent'
  } else {
    if $puppet::server::manifest {
      validate_string($puppet::server::manifest)
      $manifest_ensure = 'present'
    } else {
      $manifest_ensure = 'absent'
    }

    if $puppet::server::modulepath {
      $modulepath_ensure = 'present'
    } else {
      $modulepath_ensure = 'absent'
    }

    if $puppet::server::config_version {
      validate_string($puppet::server::config_version)
      $config_version_ensure = 'present'
    } else {
      $config_version_ensure = 'absent'
    }

    $environmentpath_ensure  = 'absent'
    $basemodulepath_ensure   = 'absent'
    $default_manifest_ensure = 'absent'
  }

  ini_setting {
    'environmentpath':
      ensure  => $environmentpath_ensure,
      setting => 'environmentpath',
      value   => $puppet::server::environmentpath;

    'basemodulepath':
      ensure  => $basemodulepath_ensure,
      setting => 'basemodulepath',
      value   => join(flatten([$puppet::server::basemodulepath]), ':');

    'default_manifest':
      ensure  => $default_manifest_ensure,
      setting => 'default_manifest',
      value   => $puppet::server::default_manifest;

    'modulepath':
      ensure  => $modulepath_ensure,
      setting => 'modulepath',
      value   => join(flatten([$puppet::server::modulepath]), ':');

    'manifest':
      ensure  => $manifest_ensure,
      setting => 'manifest',
      value   => $puppet::server::manifest;

    'config_version':
      ensure  => $config_version_ensure,
      setting => 'config_version',
      value   => $puppet::server::config_version;

    'user':
      setting => 'user',
      value   => $puppet::user;
    'group':
      setting => 'group',
      value   => $puppet::group;
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
