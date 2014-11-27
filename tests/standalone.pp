class { 'puppet::server':
  directoryenvs    => true,
  basemodulepath   => '$confdir/modules:$confdir/secure',
  environmentpath  => '$confdir/environments',
  default_manifest => 'site/site.pp',
  manage_puppetdb  => true,
  reporturl        => "https://${::fqdn}/reports",
  servertype       => 'standalone',
  ca               => true,
  reports          => [
    'https',
    'store',
    'puppetdb',
  ],
}
