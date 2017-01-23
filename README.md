# Puppet-puppet
[![Build Status](https://travis-ci.org/puppetlabs-operations/puppet-puppet.svg?branch=master)](https://travis-ci.org/puppetlabs-operations/puppet-puppet)

100% free range, organic, pesticide free Puppet module for managing Puppet.

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What puppet-puppet does and why it is useful](#module-description)
3. [Setup - getting started with puppet-puppet](#setup)
    * [What puppet-puppet affects](#what-puppet-puppet-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Puppet Master](#puppetmaster-setup)
    * [Puppet Agent](#puppet-agent-configuration)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to puppet-puppet](#development)

## Overview

The puppet-puppet module manages puppet masters and agents using puppet.

## Module Description

Puppet masters are frequently the only hand-crafted part of puppet-managed
infrastructure. This module seeks to make the experience of running a puppet
master similar to running Apache, Nginx, or MySQL using puppet.

## Setup

### What puppet-puppet affects

Depending on how you use this module, it can touch any of:
* Puppet configuration files
* Nginx or Apache configurations needed for running a master
* Unicorn and Passenger configurations and init scripts
* PuppetDB and PostgreSQL

As far as possible, this module tries to use other general-purpose modules to
configure required non-puppet systems.

### Setup Requirements

Puppet-puppet does not manage SSL certificates. You can generate the
appropriate puppet SSL certificates by starting the webrick-based puppetmaster
before using puppet-puppet. If you don't generate those SSL certs first, the
resulting master won't work. (but should if you generate the certs; it's not
strictly order dependent)

This module also doesn't manage [r10k][r10k] or [hiera][hiera-docs].
Look at [zack/r10k][zack-r10k] or [sharpie/r10k][sharpie-r10k] for r10k, and
the [hunner/hiera][hunner-hiera] module for managing hiera. If this is all
unfamiliar, read the [Shit Gary Says](http://garylarizza.com/) blog, starting
with [Building a Functional Puppet Workflow Part 1: Module Structure][sgs-1].

## Usage
There are two general areas managed with this module: masters and agents.

### Puppetmaster Setup
#### Webrick master

At an absolute minimum, you need the following.

```puppet
class { 'puppet::server':
  servertype => 'standalone',
  manifest   => '/etc/puppet/manifests/site.pp',
  ca         => true,
}
```

This should get you a puppetmaster running under `webrick` which might scale to
about `10` nodes if the wind doesn't blow too hard.

If, however, the moon is in the next phase then you probably want to use
something that scales a bit more. Your options are nginx/unicorn or
apache/passenger.

#### Nginx/Unicorn Master
The most basic setup would look something like:
```puppet
class { 'puppet::server':
  servertype => 'unicorn',
  ca         => true,
}
```

A similar Apache/Passenger server would be:
```puppet
class { 'puppet::server':
  servertype => 'passenger',
  ca         => true,
}
```

#### Certificate authority proxy configuration

If you want to automatically relay the certificate requests to an other CA you can do the following :
```puppet
class { 'puppet::server':
  servertype  => 'unicorn',
  ca          => false,
  external_ca => 'https://my_puppet_ca_server:8140',
}
```

NB: This is only implemented for Nginx/Unicorn configuration so far.

#### Master with PuppetDB, PostgreSQL, and reports
Running a puppet master without PuppetDB loses much of the utility of Puppet,
so you probably want it. As a convenience, this module will install puppetdb
and postgresql using the [puppetlabs/puppetdb][puppetlabs-puppetdb] module if
`manage_puppetdb => true` is set.

If you want a more complex setup with PuppetDB and/or PostgreSQL on a different
server, don't enable that option; use the 
[puppetlabs/puppetdb][puppetlabs-puppetdb] module directly because it has many
more configuration options that aren't exposed here.

```puppet
class { 'puppet::server':
  directoryenvs    => true,
  basemodulepath   => '$confdir/modules:$confdir/secure',
  environmentpath  => '$confdir/environments',
  default_manifest => 'site/site.pp',
  manage_puppetdb  => true,
  reporturl        => "https://${::fqdn}/reports",
  servertype       => 'unicorn',
  ca               => true,
  reports          => [
    'https',
    'store',
    'puppetdb',
  ],
}

# in a real environment, you'll probably populate parameters on these
# report classes from hiera. For this example, it's specified inline so that
# the manifest works as-is.

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


### Puppet Agent Configuration
At the most basic, simply:
```puppet
include puppet::agent
```

That will configure a cron job to run the puppet agent. If that's not what you
want, one of the following may be more to your liking:

#### Running the agent service instead of via cron
```puppet
class { 'puppet::agent':
  method => 'service',
}
```

#### Agent using cron, with more configuration options set:
Note that although the parameters correspond with puppet configuration file
option names, only a relatively subset can currently be managed with this
module.

```puppet
class { 'puppet::agent':
  server        => 'puppet.example.com',
  ca_server     => 'puppetca.example.com',
  report_server => 'puppet_reports.example.com',
  method        => 'cron',
  configtimeout => 900,
}
```

In a production environment, you should probably use `include puppet::agent`
and populate parameters using [hiera automatic parameter lookup][hiera-lookup]
instead of hardcoding these values into manifests.

## Limitations

This module is (basically) only tested on Debian Wheezy. The maintainers also
care about FreeBSD and OpenBSD support. A token gesture of EL support exists in
`params.pp` but that's about it; this probably won't do much on CentOS/RedHat.
You'll see remnants of support for Windows, Gentoo, Solaris etc in the codebase
but there's no testing or ongoing support for those platforms. They probably
don't work at all. Pull requests welcome if you're interested.

Bootstrapping an all-in-one (master, puppetdb, postgresql) puppetmaster with
puppet-puppet is relatively straightforward. However, building a usable puppet
infrastructure with it requires additional steps, such as figuring out how you
want to deploy manifests and modules to your master. (tip: use r10k)

You should definitely not use this module on an existing production
puppetmaster unless you've tested it extensively. This is a tool developed by
sysadmins, not developers, and testing is very incomplete.

## Development

Read [CONTRIBUTING.md](CONTRIBUTING.md) to see instructions on running beaker 
and rspec tests.

  [puppetlabs-puppetdb]: https://github.com/puppetlabs/puppet-puppetdb
  [puppetlabs-apache]: https://github.com/puppetlabs/puppetlabs-apache
  [puppet-nginx]: https://github.com/voxpupuli/puppet-nginx
  [r10k]: https://github.com/adrienthebo/r10k
  [hiera-lookup]: https://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup
  [hiera-docs]: https://docs.puppetlabs.com/hiera/1/
  [zack-r10k]: https://forge.puppetlabs.com/zack/r10k
  [sharpie-r10k]: https://github.com/Sharpie/puppet-r10k
  [sgs-1]: http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-1/
  [hunner-hiera]: https://github.com/hunner/puppet-hiera
