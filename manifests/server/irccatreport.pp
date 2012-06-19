# A report plugin to send irccat to IRC.
#
class puppet::server::irccatreport {

  Package{ provider => 'gem', ensure => present }

  package{
    'json':;
    'httparty':;
  }

  # This is a little bit dirty, as it just throws it straight in the
  # rubylib, but it's better than messing with libdir on the master.
  # See https://projects.puppetlabs.com/issues/4345 for mild
  # discussion.
  file{
    '/usr/lib/ruby/1.8/puppet/reports/irccat.rb':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/puppet/irccat.rb',
        notify => Class['puppet::server'];
    '/etc/puppet/irccat.yaml':
        ensure => present,
        owner  => 'root',
        group  => 'puppet',
        mode   => '0440',
        source => 'puppet:///modules/puppet/irccat.yaml',
        notify => Class['puppet::server'];
  }

}
