# -*- mode: ruby -*-
# vi: set ft=ruby :
#
APP_NAME = "bridge-preservation"
VAGRANT_USER = "vagrant"

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.network "private_network", ip: "192.168.50.4"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # enable sharing of keys after ssh-add 
  config.ssh.forward_agent = true
  
  config.vm.define APP_NAME do |rails|
    rails.vm.synced_folder ".", "/home/#{VAGRANT_USER}/app"
    rails.vm.provision :shell, path: 'provision/vagrant.sh', keep_color: true
    rails.vm.provision :shell, inline: "cd /home/#{VAGRANT_USER}/app && bin/bundle && bin/rake db:migrate && bin/rake generate_secret_token && REDMINE_LANG=en bin/rake redmine:load_default_data", privileged: false
  end
end
