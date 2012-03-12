class puppet::storeconfig::grayskull {

  include puppet::params
  include grayskull

  concat::fragment { 'puppet.conf-master-storeconfig-grayskull':
    order   => '07',
    target  => "/etc/puppet/puppet.conf",
    content => template("puppet/puppet.conf-master-storeconfigs-grayskull.erb");
  }

}
