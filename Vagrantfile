# -*- mode: ruby -*-
# vi:set ft=ruby sw=2 ts=2 sts=2:

# Definición el número de master y worker nodes
# Si el numero cambia, recuerda actualizar script setup-hosts.sh con las IP's de los nuevos hosts en /etc/hosts de cada VM.
NUM_MASTER_NODE = 1
NUM_WORKER_NODE = 0

IP_NW = "192.168.18."
MASTER_IP_START = 10
NODE_IP_START = 1
LB_IP_START = 30

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"
  # "ubuntu/focal64"
  # "ubuntu/bionic64"
  # "generic/rhel9"
  config.vm.box = "generic/ubuntu2204"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  config.vm.box_check_update = false

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Provision Master Nodes
  ###### Interface red compartida NET1
  config.vm.network "public_network", bridge: "#$default_network_interface", ip: "192.168.18.130", 
  use_dhcp_assigned_default_route: true
  ###### FIN Interface red compartida
  (1..NUM_MASTER_NODE).each do |i|
      config.vm.define "k8s-master#{i}" do |node|
        # Name shown in the GUI
        node.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-master#{i}"
            vb.memory = 14025
            vb.cpus = 4
            ###### Agregar un disco duro adicional de 20GB
            nuevo_disco_path = 'D:\Data\k8s-cluster-rook\rook_disk.vmdk'

            if !File.exist?(nuevo_disco_path)
                # Agregar un disco duro adicional de 20GB
                vb.customize ['createhd', '--filename', nuevo_disco_path, '--size', '20480']
            end
            vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', '2', '--device', '0', '--type', 'hdd', '--medium', nuevo_disco_path]
             ###### FIN Agregar un disco duro adicional de 20GB
        end
        node.vm.hostname = "k8s-master#{i}"
        # Descomentar en caso NET1 este comentado
        #node.vm.network :private_network, ip: IP_NW + "#{MASTER_IP_START + i}"
        #node.vm.network "forwarded_port", guest: 22, host: "#{2710 + i}"

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"

      end
  end


  # Provision Worker Nodes
  (1..NUM_WORKER_NODE).each do |i|
    config.vm.define "k8s-node0#{i}" do |node|
        node.vm.provider "virtualbox" do |vb|
            vb.name = "k8s-node0#{i}"
            vb.memory = 14025
            vb.cpus = 4
        end
        node.vm.hostname = "k8s-node0#{i}"
        node.vm.network :private_network, ip: IP_NW + "#{NODE_IP_START + i}"
                node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        node.vm.provision "setup-hosts", :type => "shell", :path => "ubuntu/vagrant/setup-hosts.sh" do |s|
          s.args = ["enp0s8"]
        end

        node.vm.provision "setup-dns", type: "shell", :path => "ubuntu/update-dns.sh"
    end
  end
end
