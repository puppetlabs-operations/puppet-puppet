# Puppet-puppet

100% free range, organic, pesticide free Puppet module for managing Puppet.

## Usage


### Puppetmaster

At an absolute minimum, you need the following.

``` Puppet
class { "puppet::server":
  servertype   => 'standalone',
  manifest     => '/etc/puppet/manifests/site.pp',
  ca           => true,
}
```

This should get you a puppetmaster running under `webrick` which might scale to
about `10` nodes if the wind doesn't blow too hard.

If, however, the moon is in the next phase then you probably want to use
something that scales a bit more.

``` Puppet
class service::puppet::master($servertype, $ca = false) {

  class { "::puppet::server":
    modulepath   => [
      '$confdir/modules/site',
      '$confdir/env/$environment/dist',
    ],
    storeconfigs => "puppetdb",
    reporturl    => "https://my.puppet.dashboard/reports",
    servertype   => 'unicorn',
    manifest     => '$confdir/environments/$environment/site.pp',
    ca           => $ca,
    reports      => [
      'https',
      'graphite',
      'irccat',
      'store',
    ],
  }

  include puppet::deploy
  include puppet::reports::irccat
  include puppet::reports::graphite
}
```

