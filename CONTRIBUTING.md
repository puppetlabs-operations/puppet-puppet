Testing
=======

Tests on the puppet-puppet module can be run via `rake`.

Run beaker acceptance tests:
```
BEAKER_destroy=no BEAKER_provision=no rake acceptance
```

Run beaker acceptance tests on debian 7:
```
BEAKER_set=debian-73-x64 BEAKER_destroy=no BEAKER_provision=no rake acceptance
```
See spec/acceptance/nodesets for a list of possible node names; use the filename without .yml.

Run rspec-puppet tests:
(note that these are run automatically by travis CI on pull requests)
```
rake spec
```

