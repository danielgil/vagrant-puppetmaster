# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Box settings
  config.vm.box = "puppetmaster"
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Network
  config.vm.hostname = "testmaster.innoveo.com"
  config.vm.network :forwarded_port, guest: 80, host: 10080
  config.vm.network :forwarded_port, guest: 443, host: 10443
  #config.vm.network :private_network, ip: "1.2.3.4"

  # SSH Config settings
  config.ssh.default.username = "root"
  config.ssh.forward_agent = true

  # Provisioning
  config.vm.provision :shell, :path => "shell/bootstrap-master.sh"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet"
    puppet.manifest_file = "init.pp"
    puppet.facter = {
      :dashboarduser => "puppeteer",
      :dashboardpassword => "puppeteer",
      :mysqlrootpassword => "puppeteer",
      :dashboarddbpassword => "puppeteer",
    }
  end

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "init.pp"
  # end
end
