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
}
package {
    'php5':
        ensure => installed
}
package {
    'libapache2-mod-auth-mysql':
        ensure => installed
}
package {
    'php5-mysql':
        ensure => installed
}
package {
    'php5-memcache':
        ensure => installed
}

exec { 'proxy_balancer':
        notify => Service["apache2"],
        command => '/usr/sbin/a2enmod proxy_balancer',
        require => Package["apache2"],
    }

 exec { 'proxy_http':
        notify => Service["apache2"],
        command => '/usr/sbin/a2enmod proxy_http',
        require => Package["apache2"],
    }

exec { 'mem_cache':
        notify => Service["apache2"],
        command => '/usr/sbin/a2enmod mem_cache',
        require => Package["apache2"],
    }
file {'/etc/apache2/sites-enabled/nmc.conf':
      ensure  => present,
      content => template('/etc/puppet/modules/apache/nmc.conf'),
    }
exec { 'rm_def':
        notify => Service["apache2"],
        command => '/bin/rm /etc/apache2/sites-enabled/000-default',
       require => Package["apache2"],
    }

exec { 'reset_apache':
        notify => Service["apache2"],
        command => '/etc/init.d/apache2 restart',
        require => Package["apache2"],
    }
		">/etc/puppet/manifests/site.pp
sudo echo "node 'lb0.kapsch.co.at' {
   include apache2
   include php5
 include libapache2-mod-auth-mysql
 include php5-mysql
 include php5-memcache
 include /etc/apache2/sites-enabled/nmc.conf
 include rm_def
 include reset_apache
}
">/etc/puppet/manifests/nodes.pp
sudo mkdir /etc/puppet/modules/apache
sudo echo "<VirtualHost *:80>
        ProxyRequests off

        ServerName NMC
        <Proxy balancer://NMC>
                # WebHead1
                BalancerMember http://192.168.10.11:80
                # WebHead2
                BalancerMember http://192.168.10.12:80
                # Security 'technically we aren't blocking anyone but this the place to make those chages
                Order Deny,Allow
                Deny from none
                Allow from all
                # Load Balancer Settings We will be configuring a simple Round Robin style load balancer.  This means that all webheads take an equal share of of the load.
                ProxySet lbmethod=byrequests
        </Proxy>
        # balancer-manager This tool is built into the mod_proxy_balancer module and will allow you to do some simple modifications to the balanced group via a gui web interface.
        <Location /balancer-manager>
                SetHandler balancer-manager
                # I recommend locking this one down to your your office
                Order deny,allow
                Allow from all
        </Location>
        # Point of Balance This setting will allow to explicitly name the the location in the site that we want to be balanced, in this example we will balance "/" or everything in the site.
        ProxyPass /balancer-manager !
        ProxyPass / balancer://NMC/
</VirtualHost>

">/etc/puppet/modules/apache/nmc.conf
sudo service puppetmaster restart
sudo puppetca --sign lb0


