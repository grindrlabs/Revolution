# -*- coding: utf-8 -*-
# frozen_string_literal: true

# vi: set ft=ruby :

require 'etc'
require 'shellwords'

Vagrant.configure('2') do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'bento/centos-7.4'
  config.vm.hostname = 'revolution-dev'

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network 'private_network', type: 'dhcp'

  # ssh forward agent
  config.ssh.forward_agent = true
  # send the aws keys
  config.ssh.forward_env = %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN]

  # Tweak the VMs configuration.
  config.vm.provider 'virtualbox' do |v|
    v.cpus = [Etc.nprocessors, 2].min
    v.linked_clone = true if Vagrant::VERSION =~ /^1.8/
  end

  config.vm.synced_folder '.', '/vagrant/',
                          id: 'tool',
                          mount_options: ['uid=1000', 'gid=1000']

  # Configure the VM using Ansible
  config.vm.provision :ansible do |ansible|
    ansible.galaxy_role_file = 'requirements.yml'
    ansible.galaxy_roles_path = '.galaxy-roles'
    ansible.playbook = 'vagrant.yml'
    # allow passing ansible args from environment variable
    ansible.raw_arguments = Shellwords.shellwords(ENV.fetch('ANSIBLE_ARGS', ''))
  end
end
