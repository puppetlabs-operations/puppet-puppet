# A report plugin to send irccat to IRC.
#
class puppet::reports::irccat($host, $githuburl, $dashboard, $ignore_hosts = []) {

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
    "${puppet::server::report_dir}/irccat.rb":
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/puppet/reports/irccat.rb',
      notify => Class['puppet::server'];
    '/etc/puppet/irccat.yaml':
      ensure  => present,
      owner   => 'root',
      group   => 'puppet',
      mode    => '0440',
      content => template('puppet/reports/irccat.yaml.erb'),
      notify  => Class['puppet::server'];
  }
}
