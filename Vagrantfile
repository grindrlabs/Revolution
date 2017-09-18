#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# vi: set ft=ruby :

require 'etc'
require 'shellwords'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def cpu_count
  4
end

def memory
  4096
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/centos-7.3"
  config.vm.hostname = "revolution-dev"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", type: "dhcp"

  # ssh forward agent
  config.ssh.forward_agent = true
  # send the aws keys
  config.ssh.forward_env = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_SESSION_TOKEN"]

  # Tweak the VMs configuration.
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = cpu_count
    vb.memory = memory
    vb.linked_clone = true
  end

  config.vm.synced_folder ".", "/vagrant/",
      id: "tool", nfs: "true"

  config.vm.synced_folder "../rpm-packages/", "/vagrant/recipes/",
      id: "recipes", nfs: "true"

  # Configure the VM using Ansible
  config.vm.provision "ansible_local" do |ansible|
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_roles_path = ".galaxy-roles"
    ansible.provisioning_path = "/vagrant"
    ansible.playbook = "vagrant.yml"
    # allow passing ansible args from environment variable
    ansible.raw_arguments = Shellwords::shellwords(ENV.fetch("ANSIBLE_ARGS", ""))
  end
end
