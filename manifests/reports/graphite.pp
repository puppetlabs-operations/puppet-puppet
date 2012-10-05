# A report plugin to send metrics to graphite
# From https://github.com/nareshov/puppet-graphite
#
class puppet::reports::graphite {

  include puppet::reports

  # This is a little bit dirty, as it just throws it straight in the
  # rubylib, but it's better than messing with libdir on the master.
  # See https://projects.puppetlabs.com/issues/4345 for mild
  # discussion.
  file{
    "/${puppet::reports::report_dir}/graphite.rb":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/puppet/reports/graphite.rb';
    '/etc/puppet/graphite.yaml':
      ensure => present,
      owner  => 'root',
      group  => 'puppet',
      mode   => '0440',
      source => 'puppet:///modules/puppet/reports/graphite.yaml';
  }

  # We could, at this, tell Puppet we need to bounce it, but I think
  # would be bold.
}
