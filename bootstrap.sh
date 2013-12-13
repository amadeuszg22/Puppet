#!/usr/bin/env bash

echo "System will install server features"
echo  "192.168.10.10 LB0 lb0">>/etc/hosts
echo "System Upgrades repositories"
sudo apt-get update
echo "System install master of puppets"
apt-get install libopenssl-ruby rdoc irb1.8 libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 rdoc1.8 ruby1.8 -y
sudo apt-get install puppet -y
sudo apt-get install puppetmaster -y
sudo apt-get install git -y
sudo echo "package {
    'apache2':
        ensure => installed
}

service {
    'apache2':
        ensure => true,
        enable => true,
        require => Package['apache2']
}">/etc/puppet/manifests/site.pp
sudo echo "node 'lb0.kapsch.co.at' {
   include apache2
}">/etc/puppet/manifests/nodes.pp
sudo service puppetmaster restart
sudo puppetca --sign lb0.kapsch.co.at
