# Puppet-puppet

100% free range, organic, pesticide free Puppet module for managing Puppet.

## Usage


### Puppetmaster

At an absolute minimum, you need the following.

    class { "puppet::server":
      servertype   => 'standalone',
      manifest     => '/etc/puppet/manifests/site.pp',
      ca           => true,
    }

This should get you a puppetmaster running under `webrick` which might scale to
about `10` nodes if the wind doesn't blow too hard.

If, however, the moon is in the next phase then you probably want to use
something that scales a bit more.

    class service::puppet::master($servertype, $ca = false) {

      $modulepath = hiera_array('puppet_modulepath')

      class { "::puppet::server":
        modulepath   => inline_template("<%= modulepath.join(':') %>"),
        storeconfigs => "puppetdb",
        reporturl    => "https://dashboard.puppetlabs.com/reports",
        servertype   => 'unicorn',
        manifest     => '$confdir/environments/$environment/site.pp',
        ca           => $ca,
        reports      => [
          'https',
          'graphite',
          'irccat',
          'store', # (#16894) Nick wants nice report data for puppetdb.
        ],
      }

      include puppet::deploy
      include puppet::reports::irccat
      include puppet::reports::graphite

    }


