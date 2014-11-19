# Puppet-puppet
[![Build Status](https://travis-ci.org/puppetlabs-operations/puppet-puppet.svg?branch=master)](https://travis-ci.org/puppetlabs-operations/puppet-puppet)

100% free range, organic, pesticide free Puppet module for managing Puppet.


## Usage


### Puppetmaster

At an absolute minimum, you need the following.

``` Puppet
class { 'puppet::server':
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
class { '::puppet::server':
  modulepath   => [
    '$confdir/modules/site',
    '$confdir/env/$environment/dist',
  ],
  storeconfigs => 'puppetdb',
  reporturl    => "https://${::fqdn}/reports",
  servertype   => 'unicorn',
  manifest     => '$confdir/environments/$environment/site.pp',
  ca           => true,
  reports      => [
    'https',
    'graphite',
    'irccat',
    'store',
  ],
}

# in a real environment, you'll probably populate parameters on these
# report classes from hiera. For this example, it's specified inline so that
# the manifest works as-is

class { 'puppet::reports::graphite':
  server => $::fqdn,
  port   => 2003,
  prefix => 'puppetmaster'
}

class { 'puppet::reports::irccat':
  host      => $::fqdn,
  githuburl => 'https://github.com/example/foo',
  dashboard => 'https://dashboard.example.com',
}
```

