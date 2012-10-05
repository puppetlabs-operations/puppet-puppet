class puppet::reports {
  $report_dir = $puppet_major_version ? {
    '3' => '/usr/lib/ruby/vendor_ruby/puppet/reports',
    '2' => '/usr/lib/ruby/1.8/puppet/reports',
  }
}
