#!/bin/bash

apt-get update
apt-get install -y git puppet rubygems
cd /etc/puppet/modules
git clone https://github.com/jtopjian/puppet-puppet puppet
git clone https://github.com/puppetlabs/puppetlabs-apt apt
git clone -b 3.x https://github.com/puppetlabs/puppetlabs-stdlib stdlib
git clone https://github.com/puppetlabs/puppetlabs-concat concat
git clone https://github.com/puppetlabs/puppetlabs-ruby ruby
git clone https://github.com/puppetlabs/puppetlabs-apache apache
git clone https://github.com/puppetlabs/puppetlabs-passenger passenger
git clone https://github.com/puppetlabs/puppetlabs-firewall firewall
git clone https://github.com/puppetlabs/puppetlabs-puppetdb puppetdb
git clone https://github.com/cprice-puppet/puppetlabs-inifile inifile

cd /etc/puppet
for i in production development
do
  mkdir -p env/$i/{modules,manifests}
done
