require 'yaml'
confDir = File.expand_path("~/.huyhvqvagrant")
confFile = confDir + "/config.yaml"

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  settings = YAML::load(File.read(confFile))
  # puts settings
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: settings["ip"]
  config.vm.synced_folder settings["mapFolder"], settings["toFolder"]

  config.vm.provider "virtualbox" do |v|
    v.name = "huyhvq_api"
    v.memory = settings["memory"]
  end
  config.vm.provision "shell" do |s|
      s.path = "scripts/setup.sh"
  end

  config.vm.provision "shell" do |s|
    s.path = "scripts/nginx.sh"
    s.args = [settings["mapSite"],settings["toSite"]]
  end
end
