# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.1.2"

# The "2" is configuration version
Vagrant.configure("2") do |config|
	# https://docs.vagrantup.com.	(complete reference)
	
	#==============================================================================================
	# BOX
	#==============================================================================================
	# Every Vagrant development environment requires a box. You can search for boxes at
	# https://app.vagrantup.com/boxes/search
	
	config.vm.box = "ubuntu/bionic64"
	#config.vm.box_version = "20180814.0.0"
	#config.vm.communicator = "winrm"
	
	# Disable automatic box update checking. If you disable this,
	# then boxes will only be checked for updates when the user runs:
	# `vagrant box outdated`
	# This is not recommended.
	config.vm.box_check_update = true
	#==============================================================================================
	# FORWARDED PORT MAPPING
	#==============================================================================================
	# Create a forwarded port mapping which allows access to a specific port
	# within the machine from a port on the host machine and only allow access via 127.0.0.1 to disable public access.
	
	config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1", auto_correct: true
	config.vm.network "forwarded_port", guest: 5432, host: 65432, host_ip: "127.0.0.1", auto_correct: true
	config.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1", auto_correct: true
	config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "127.0.0.1", auto_correct: true
	#==============================================================================================
	# NETWORK
	#==============================================================================================
	# Create a private network, which allows host-only access to the machine
	# using a specific IP.
	config.vm.network "private_network", ip: "192.168.33.10"
	
	# Create a public network, which generally matched to bridged network.
	# Bridged networks make the machine appear as another physical device on your network.
	# config.vm.network "public_network", ip: "192.168.0.17"
	#==============================================================================================
	# SYNCED FOLDERS
	#==============================================================================================
	# Share an additional folder to the guest VM.
	# The first argument is the path on the host to the actual folder.
	# The second argument is the path on the guest to mount the folder.
	# And the optional third argument is a set of non-required options.
	#
	# Example: 
	# config.vm.synced_folder "C:/test", "/vagrant/html/test", disabled: false (Accessible from http://v.loc/test)
	#
	config.vm.synced_folder ".", "/vagrant", disabled: false
	#==============================================================================================
	# PROVIDER
	#==============================================================================================
	# Provider-specific configuration so you can fine-tune various backing providers for Vagrant.
	# These expose provider-specific options.
	# Example for VirtualBox:
	#
	# config.vm.provider "virtualbox" do |vb|
	#   # Display the VirtualBox GUI when booting the machine
	#   vb.gui = true
	#
	#   # Customize the amount of memory on the VM:
	#   vb.memory = "1024"
	# end
	#
	#==============================================================================================
	# PROVISION
	#==============================================================================================
	# Enable provisioning with a shell script.
	# Additional provisioners such as Puppet, Chef, Ansible, Salt, and Docker are also available.
	# Inline example:
	#
	# config.vm.provision "shell", inline: <<-SHELL
	#   apt-get update
	#   apt-get install -y apache2
	# SHELL
	#
	config.vm.provision :shell, path: ".provision/nginx/bootstrap.sh"
end
