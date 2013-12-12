Vagrant.configure("2") do |config|  
  config.vm.box = "Test"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
 
  	config.vm.define :LB do |lb| 
    lb.vm.hostname = "LB0"
    lb.vm.network :private_network, ip: "192.168.10.10"    
	lb.vm.provision :shell, :path => "bootstrapLB0.sh"  
  end
  config.vm.define :pp do |pp| 
    pp.vm.hostname = "puppet"
    pp.vm.network :private_network, ip: "192.168.10.9"    
	pp.vm.provision :shell, :path => "bootstrap.sh"
  end

end