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

    if ! empty($puppet::server::basemodulepath) {
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

    if ! empty($puppet::server::modulepath) {
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

  ini_setting { 'environmentpath':
    ensure  => $environmentpath_ensure,
    setting => 'environmentpath',
    value   => $puppet::server::environmentpath,
  }

  ini_setting { 'basemodulepath':
    ensure  => $basemodulepath_ensure,
    setting => 'basemodulepath',
    value   => join(flatten([$puppet::server::basemodulepath]), ':'),
  }

  ini_setting { 'default_manifest':
    ensure  => $default_manifest_ensure,
    setting => 'default_manifest',
    value   => $puppet::server::default_manifest,
  }

  ini_setting { 'modulepath':
    ensure  => $modulepath_ensure,
    setting => 'modulepath',
    value   => join(flatten([$puppet::server::modulepath]), ':'),
  }

  ini_setting { 'manifest':
    ensure  => $manifest_ensure,
    setting => 'manifest',
    value   => $puppet::server::manifest,
  }

  ini_setting { 'config_version':
    ensure  => $config_version_ensure,
    setting => 'config_version',
    value   => $puppet::server::config_version,
  }

  ini_setting { 'user':
    setting => 'user',
    value   => $puppet::user,
  }

  ini_setting { 'group':
    setting => 'group',
    value   => $puppet::group,
  }

  ini_setting { 'stringify_facts_master':
    setting => 'stringify_facts',
    section => 'main',
    value   => $puppet::server::stringify_facts,
  }

  ini_setting { 'ca':
    setting => 'ca',
    value   => $puppet::server::ca,
  }

  if $puppet::server::servertype == 'standalone' and $puppet::server::bindaddress {
    $bindaddress_ensure = 'present'
  } else {
    $bindaddress_ensure = 'absent'
  }

  ini_setting { 'bindaddress':
    ensure  => $bindaddress_ensure,
    setting => 'bindaddress',
    value   => $puppet::server::bindaddress,
  }

  if $puppet::server::ssl_client_header {
    $ssl_client_ensure = 'present'
  } else {
    $ssl_client_ensure = 'absent'
  }

  ini_setting { 'ssl_client_header':
    ensure  => $ssl_client_ensure,
    setting => 'ssl_client_header',
    value   => $puppet::server::ssl_client_header,
  }

  ini_setting { 'ssl_client_verify_header':
    ensure  => $ssl_client_ensure,
    setting => 'ssl_client_verify_header',
    value   => $puppet::server::ssl_client_verify_header,
  }

  if ! empty($puppet::server::reports) {
    $reports_ensure = 'present'
  } else {
    $reports_ensure = 'absent'
  }

  ini_setting { 'reports':
    ensure  => $reports_ensure,
    setting => 'reports',
    value   => join(flatten([ $puppet::server::reports ]), ', '),
  }

  if ! empty($puppet::server::reporturl) {
    $reporturl_ensure = 'present'
  } else {
    $reporturl_ensure = 'absent'
  }

  ini_setting { 'reporturl':
    ensure  => $reporturl_ensure,
    setting => 'reporturl',
    value   => $puppet::server::reporturl,
  }

  if $puppet::server::reportfrom {
    $reportfrom_ensure = 'present'
  } else {
    $reportfrom_ensure = 'absent'
  }

  ini_setting { 'reportfrom':
    ensure  => $reportfrom_ensure,
    setting => 'reportfrom',
    value   => $puppet::server::reportfrom,
  }

  if $puppet::server::enc == 'exec' {
    $enc_ensure = 'present'
  } else {
    $enc_ensure = 'absent'
  }

  ini_setting { 'node_terminus':
    ensure  => $enc_ensure,
    setting => 'node_terminus',
    value   => 'exec',
  }

  ini_setting { 'external_nodes':
    ensure  => $enc_ensure,
    setting => 'external_nodes',
    value   => $puppet::server::enc_exec,
  }

  if $puppet::server::parser {
    $parser_ensure = 'present'
  } else {
    $parser_ensure = 'absent'
  }

  ini_setting { 'parser':
    ensure  => $parser_ensure,
    setting => 'parser',
    value   => $puppet::server::parser,
  }

  if ! empty($puppet::server::dns_alt_names) {
    $dns_alt_names_ensure = 'present'
  } else {
    $dns_alt_names_ensure = 'absent'
  }

  ini_setting { 'dns_alt_names':
    ensure  => $dns_alt_names_ensure,
    setting => 'dns_alt_names',
    value   => join(flatten([ $puppet::server::dns_alt_names ]), ', ')
  }

  if $puppet::server::autosign {
    $autosign_ensure = 'present'
  } else {
    $autosign_ensure = 'absent'
  }

  ini_setting { 'autosign':
    ensure  => $autosign_ensure,
    setting => 'autosign',
    value   =>  $puppet::server::autosign,
  }
}
