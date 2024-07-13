# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "almalinux/8"
  config.vm.box_check_update = false

  # Define the number of worker nodes
  NUM_WORKER_NODES = 2

  # Kubernetes Master Node
  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.26.11"
    master.vm.provider "virtualbox" do |vb|
      vb.name = "k8s-master"
      vb.memory = 2048
      vb.cpus = 2
      vb.linked_clone = true
    end
    master.vm.provision "shell", path: "provision-master.sh"
  end

  # Kubernetes Worker Nodes
  (1..NUM_WORKER_NODES).each do |i|
    config.vm.define "k8s-worker-#{i}" do |worker|
      worker.vm.hostname = "k8s-worker-#{i}"
      worker.vm.network "private_network", ip: "192.168.26.#{i + 10}"
      worker.vm.provider "virtualbox" do |vb|
        vb.name = "k8s-worker-#{i}"
        vb.memory = 1024
        vb.cpus = 1
        vb.linked_clone = true
      end
      worker.vm.provision "shell", path: "provision-worker.sh"
    end
  end

  # Disable synced folders for better performance
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
