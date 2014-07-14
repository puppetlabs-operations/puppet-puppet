Testing
=======

Tests on the puppet-puppet module can be run via `rake`.

#### Beaker acceptance tests
```
BEAKER_destroy=no BEAKER_provision=onpass rake acceptance
```

Run beaker acceptance tests on debian 7:
```
BEAKER_set=debian-73-x64 BEAKER_destroy=onpass BEAKER_provision=no rake acceptance
```
See spec/acceptance/nodesets for a list of possible node names; use the filename without .yml.

If a beaker test fails, you can SSH into the environment if you use BEAKER_PROVISION=onpass.
The path of the vagrantfile will be `.vagrant/beaker_vagrant_files/debian-73-x64.yml`
if you followed the above instructions, and slightly different if you used a
different nodeset. `cd` to that directory and `vagrant ssh` to access the VM.
The tests that ran are in /tmp with randomly generated filenames.
```

#### rspec-puppet tests
(note that these are run automatically by travis CI on pull requests)
```
rake spec
```

Vagrant
=======

This project includes a Vagrantfile to facilitate development. The purpose of
the Vagrantfile is to give you an easy way to interactively edit code and run
tests without polluting your workstation, and without having to worry about
deploying code constantly to test minor changes.

The recommended way to use this for iteratively working out changes is:
```
rm -rf pkg
rake build
vagrant up shared_folder
vagrant ssh shared_folder
```

This will build a new package you could upload to puppetforge in the pkg
directory. Vagrant will use that to install dependencies, but will mount the
repository to /etc/puppet/modules/puppet so your changes take effect
immediately.

A second vagrant environment exists for testing packages prior to puppetforge
release. A typical workflow might be:
```bash
rm -rf pkg
rake build
vagrant up package_install
vagrant ssh package_install
```

Once in one of these systems, the tests in /vagrant/tests may be helpful for
testing during development.

Finally, an agent VM is provided to help test client-server interaction:

```bash
vagrant up agent
vagrant ssh agent
sudo puppet agent --test --waitforcert 10 --server puppet
```
