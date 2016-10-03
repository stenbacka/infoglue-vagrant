# -*- mode: ruby -*-
# vi: set ft=ruby :

def createIfMissing(folder_name)
	unless Dir.exists?(folder_name)
		puts "Creating directory " + folder_name
		Dir.mkdir folder_name
	end
end

Vagrant.configure(2) do |config|
	config.vm.box = "bento/ubuntu-16.04"

	# Fixes annoying error message
	config.vm.provision "fix-no-tty", type: "shell" do |s|
		s.privileged = false
		s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
	end

	# Setup Infoglue source code
	unless Dir.exists?("infoglue") and File.exists?("infoglue/build.xml")
		puts "Checking out Infoglue"
		system("git submodule update --init --recursive")
	end

	# Create privates network
	config.vm.network "private_network", ip: "192.168.13.37"

	# Setup shares
	createIfMissing "webapps"
	createIfMissing "components"
	config.vm.synced_folder "webapps", "/opt/tomcat/webapps", type: "nfs"
	config.vm.synced_folder "components", "/var/infoglue/components", type: "nfs"

	# Virtualbox config
	config.vm.provider "virtualbox" do |vb|
		vb.memory = "1024"
		vb.customize ["modifyvm", :id, "--memory", "1024"]
	end

	# Run provisioning scripts
	config.vm.provision "shell", path: "provision/setup.sh"
end
