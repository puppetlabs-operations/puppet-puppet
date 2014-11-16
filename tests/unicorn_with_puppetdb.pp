class { '::puppet::server':
  modulepath      => [
    '$confdir/modules',
    '$confdir/environments/$environment/modules/site',
    '$confdir/environments/$environment/modules/site/dist',
    '$confdir/environments/$environment/modules/site/dist',
  ],
  manage_puppetdb => true,
  reporturl       => "https://${::fqdn}/reports",
  servertype      => 'unicorn',
  manifest        => '$confdir/environments/$environment/site.pp',
  ca              => true,
  reports         => [
    'https',
    'store',
    'puppetdb',
  ],
}
