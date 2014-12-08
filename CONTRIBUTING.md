Testing
=======

Puppet-puppet is tested via beaker and rspec-puppet. Rspec-puppet tests are run
automatically for pull requests via travis-ci, or can be triggered manually
by running `rake spec` after doing a `bundle install`.

Beaker tests are run slightly differently for puppet-puppet than for other
beaker-tested projects because the test suite should be run independently for
each test case to prevent contamination between environments. For example,
running the apache-passenger based puppet master test case will cause obvious
conflicts if the nginx-unicorn puppet master is subsequently built on the same
virtual machine. Rspec tags are used to accomplish this in the test cases.

Running beaker tests for unicorn puppetmaster on the default nodeset (debian 7):
```bash
rspec . --tag servertype:unicorn --pattern "spec/acceptance/**/*_spec.rb"
```

Same as above, but only only destroying the VM if the build is successful, to
help troubleshooting:
```
BEAKER_destroy=onpass BEAKER_provision=yes rspec . --tag servertype:unicorn --pattern "spec/acceptance/**/*_spec.rb"
```

Same as above, but on a different nodeset (see `spec/acceptance/nodesets` for
options):
```bash
BEAKER_set=sles-11sp1-x64 BEAKER_destroy=onpass BEAKER_provision=yes rspec . --tag servertype:unicorn --pattern "spec/acceptance/**/*_spec.rb"
```

The presence of an OS/distro in the nodeset list does not imply support. The
SLES example above is expected to fail most test cases but is included to lower
the bar for future contributors who want to add support for additional distros.

The rake command includes acceptance testing tasks, but these should not be
used because they will run all of the acceptance tests on the same VM, which
is expected to fail.

If a beaker test fails, you can SSH into the environment if you use BEAKER_PROVISION=onpass.
The path of the vagrantfile will be `.vagrant/beaker_vagrant_files/debian-73-x64.yml`
if you followed the above instructions, and slightly different if you used a
different nodeset. `cd` to that directory and `vagrant ssh` to access the VM.
The tests that ran are in /tmp with randomly generated filenames.

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

How to Deploy to Puppet Forge
=============================

To perform a release:

1) Update the metadata.json file with the new version, and commit the change
2) Tag that commit with an annotated commit: `git tag -a 0.13.0 -m 'release 0.13.0'`
3) Make a pull request so that another contributor can merge the PR
4) When that commit is merged, travis-ci will run and deploy to Puppet Forge
5) Check the travis-ci output and forge site to verify that it deployed

Versioning
----------
Release versions should follow [semver](http://semver.org/) guidelines:

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> MAJOR version when you make incompatible API changes,
> MINOR version when you add functionality in a backwards-compatible manner, and
> PATCH version when you make backwards-compatible bug fixes.

Update Changelog
----------------
Notable changes should be added to [CHANGELOG](CHANGELOG).

Run Beaker Tests
----------------
Pplease run beaker acceptance test suite before releasing. At the moment,
those tests only run manually, without any Jenkins/CI-triggered acceptance
tests. At the very least, the acceptance tests should be run for Debian 7.
