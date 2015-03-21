# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    ### Define options for all VMs ###
    # Using vagrant-cachier improves performance if you run repeated yum/apt updates
    if defined? VagrantPlugins::Cachier
      config.cache.auto_detect = true
    end
    config.ssh.forward_agent = true

    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "512", "--cpus", "4", "--ioapic", "on"]
    end
    # hack to avoid ubuntu/debian-specific 'stdin: is not a tty' error on startup
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # distro-agnostic puppet install script from https://github.com/danieldreier/puppet-installer
    config.vm.provision "shell", inline: "curl getpuppet.whilefork.com | bash"

    PUPPETMASTER_IP = '192.168.37.23'

    config.vm.define :debian7 do |node|
      node.vm.box = 'puppetlabs/debian-7.6-64-nocm'
      node.vm.hostname = 'debian7.boxnet'
      config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "4", "--ioapic", "on"]
      end
    end

    config.vm.define :freebsd10 do |node|
      node.vm.box = 'chef/freebsd-10.0'
      node.vm.hostname = 'freebsd10.boxnet'
      config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096", "--cpus", "4", "--ioapic", "on"]
      end
    end

    config.vm.define :package_install do |node|
      node.vm.box = 'puppetlabs/debian-7.6-64-nocm'
      node.vm.hostname = 'debian7.boxnet'
      node.vm.network :private_network, ip: PUPPETMASTER_IP

      # hack to avoid ubuntu/debian-specific 'stdin: is not a tty' error on startup
      node.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

      # distro-agnostic puppet install script from https://github.com/danieldreier/puppet-installer
      node.vm.provision "shell", inline: "curl getpuppet.whilefork.com | bash"

      # use a packaged version of puppet-puppet to install dependencies via the forge
      # rm removes symlink from next step for vagrant provision idempotency
      node.vm.provision "shell",
        inline: "rm -rf /etc/puppet/modules/puppet"
      node.vm.provision "shell",
        inline: "if ls /vagrant/pkg/ploperations-puppet-*.tar.gz ; then puppet module install /vagrant/pkg/ploperations-puppet-*.tar.gz; fi"
    end

    config.vm.define :shared_folder do |node|
      node.vm.box = 'puppetlabs/debian-7.6-64-nocm'
      node.vm.hostname = 'debian7.boxnet'
      node.vm.network :private_network, ip: PUPPETMASTER_IP

      # use a packaged version of puppet-puppet to install dependencies via the forge
      # rm removes symlink from next step for vagrant provision idempotency
      node.vm.provision "shell",
        inline: "rm -rf /etc/puppet/modules/puppet"
      node.vm.provision "shell",
        inline: "if ls /vagrant/pkg/ploperations-puppet-*.tar.gz ; then puppet module install /vagrant/pkg/ploperations-puppet-*.tar.gz; rm -rf /etc/puppet/modules/puppet; fi"

      # if this was done as a vagrant shared folder, the previous step either
      # wouldn't run or would overwrite files this approach allows using
      # puppet's facilities for installing dependencies while also keeping a
      # shared folder to simplify development
      node.vm.provision "shell",
        inline: "ln -s /vagrant /etc/puppet/modules/puppet"
    end

    config.vm.define :agent do |node|
      node.vm.box = 'puppetlabs/debian-7.6-64-nocm'
      node.vm.hostname = 'debian7agent.boxnet'
      node.vm.network :private_network, ip: "192.168.37.25"
      node.vm.provision "shell",
        inline: "if ! grep #{PUPPETMASTER_IP} /etc/hosts; then echo '#{PUPPETMASTER_IP} puppet' >> /etc/hosts; fi"
    end
end
