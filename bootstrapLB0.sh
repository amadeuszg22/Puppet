#!/usr/bin/env bash

echo "System will install server features"
echo  "127.0.0.1 lb0 LB0
			192.168.10.10 LB0 lb0
			192.168.10.9 puppet PUPPET">>/etc/hosts
echo "System Upgrades repositories"
sudo apt-get update
sudo apt-get install libopenssl-ruby rdoc irb1.8 libopenssl-ruby1.8 libreadline-ruby1.8 libruby1.8 rdoc1.8 ruby1.8 -y
sudo apt-get install facter puppet -y
sudo apt-get install screen -y
sudo apt-get install git -y
sudo echo "[puppetd]
server = 192.168.10.9

# Make sure all log messages are sent to the right directory
# This directory must be writable by the puppet user
logdir=/var/log/puppet
vardir=/var/lib/puppet
rundir=/var/run">/etc/puppet/puppetd.conf
 sudo echo "# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=yes

# Startup options
DAEMON_OPTS=""

">/etc/default/puppet
sudo echo "[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post
runinterval=30

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
">/etc/puppet/puppet.conf
sudo /etc/init.d/puppet start



