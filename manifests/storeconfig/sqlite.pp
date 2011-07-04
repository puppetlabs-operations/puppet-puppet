class puppet::storeconfig::sqlite {

  concat::fragment { 'puppet.conf-master-storeconfig-sqlite':
    order   => '07',
    target  => "/etc/puppet/puppet.conf",
    content => "dblocation = /var/lib/puppet/storeconfigs.sqlite";
  }

}
