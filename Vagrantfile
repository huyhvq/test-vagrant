vhostMap = "/vagrant_data/huyhvq/public"
vhostTo = "huyhvq.app"
Vagrant.configure(2) do |config|
  config.vm.box = "laravel/homestead"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.55.10"
  config.vm.synced_folder "~/Code", "/vagrant_data"

  config.vm.provider "virtualbox" do |v|
    v.name = "huyhvq_api"
    v.memory = "2048"
  end
  config.vm.provision "shell" do |s|
      s.path = "scripts/setup.sh"
  end

  config.vm.provision "shell" do |s|
    s.path = "scripts/setup.sh"
    s.args = [vhostMap,vhostTo]
  end
end
