require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host['platform'] =~ /debian/
      # debian 6 doesn't have gems in path by default
      on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
    end
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

#agents = hosts_as :agent
#agents.each do |host|
#  on host, 'touch /tmp/agent_test'
#end

masters = hosts_as :master
masters.each do |host|

  on host, 'touch /etc/puppet/hiera.yaml'
  # Install r10k for installing modules from github
  # This is a bit of a hack but necessary because these dependencies do not
  # have recent versions available on puppetforge
  install_package host, 'rubygems'
  install_package host, 'git'
  on host, 'hash r10k || gem install r10k --no-ri --no-rdoc'

  puppetfile = <<-EOS
mod 'stdlib',         :git => 'git://github.com/puppetlabs/puppetlabs-stdlib.git'
mod 'apt',         :git => 'git://github.com/puppetlabs/puppetlabs-apt.git'
mod 'concat',         :git => 'git://github.com/puppetlabs/puppetlabs-concat.git'
mod 'ruby',           :git => 'git://github.com/puppetlabs/puppetlabs-ruby.git'
mod 'puppetlabs_yum', :git => 'git://github.com/stahnma/puppet-module-puppetlabs_yum'
mod 'puppetlabs_apt', :git => 'git://github.com/puppetlabs-operations/puppet-puppetlabs_apt.git'
mod 'interval',       :git => 'git://github.com/puppetlabs-operations/puppet-interval.git'
mod 'unicorn',        :git => 'git://github.com/puppetlabs-operations/puppet-unicorn.git'
mod 'rack',           :git => 'git://github.com/puppetlabs-operations/puppet-rack.git'
mod 'bundler',        :git => 'git://github.com/puppetlabs-operations/puppet-bundler.git'
mod 'nginx',          :git => 'git://github.com/puppetlabs-operations/puppet-nginx.git'
mod 'inifile',        :git => 'git://github.com/puppetlabs/puppetlabs-inifile.git'
mod 'apache',         :git => 'git://github.com/puppetlabs/puppetlabs-apache.git'
mod 'portage',        :git => 'git://github.com/gentoo/puppet-portage.git'
  EOS
  on host, "echo \"#{puppetfile}\" > /etc/puppet/Puppetfile"
  on host, "cd /etc/puppet; r10k puppetfile install"

  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  puppet_module_install(:source => proj_root, :module_name => 'puppet')

  # Generate CA cert because it's necessary for puppet masters but not
  # within the scope of the puppet module
  on host, "rm -rf /var/lib/puppet/ssl; puppet cert --generate $HOSTNAME"

end
