# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false

  config.vm.synced_folder "./", "/pgdev"

  config.vm.provision "shell", inline: <<-SHELL
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql-13 postgresql-server-dev-13 make gnuplot gcc

    sudo -i -u postgres createuser -d -r -s vagrant
    sudo -i -u postgres createdb vagrant
    
    sudo bash
    echo "local all all trust" > /etc/postgresql/13/main/pg_hba.conf 
    service postgresql restart
  SHELL
end