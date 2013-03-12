class puppet::reports {
  $report_dir = $puppet_major_version ? {
    '2'     => '/usr/lib/ruby/1.8/puppet/reports',
    '3'     => '/usr/lib/ruby/vendor_ruby/puppet/reports',
    default => '/usr/lib/ruby/vendor_ruby/puppet/reports',
  }
}
