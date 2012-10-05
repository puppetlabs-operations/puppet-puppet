# A report plugin to send irccat to IRC.
#
class puppet::reports::irccat {

  Package{ provider => 'gem', ensure => present }

  package{
    'json':;
    'httparty':;
  }

  require puppet::reports

  # This is a little bit dirty, as it just throws it straight in the
  # rubylib, but it's better than messing with libdir on the master.
  # See https://projects.puppetlabs.com/issues/4345 for mild
  # discussion.
  file{
    "${puppet::reports::report_dir}/irccat.rb":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/puppet/reports/irccat.rb',
      notify => Class['puppet::server'];
    '/etc/puppet/irccat.yaml':
      ensure => present,
      owner  => 'root',
      group  => 'puppet',
      mode   => '0440',
      source => 'puppet:///modules/puppet/reports/irccat.yaml',
      notify => Class['puppet::server'];
  }
}
