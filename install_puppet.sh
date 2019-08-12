#!/bin/bash

su -
cd /tmp
wget http://apt.puppetlabs.com/puppet5-release-stretch.deb
dpkg -i puppet5-release-stretch.deb
apt-get update


apt-get install -y puppet-agent puppetserver
export PATH=/opt/puppetlabs/bin:$PATH
echo "export PATH=/opt/puppetlabs/bin:\$PATH" >> /etc/bash.bashrc

puppet --version

nano /etc/puppetlabs/puppet/puppet.conf
nano /etc/default/puppetserver JAVA_ARGS="-Xms256m -Xmx512m"

service puppetserver restart

puppet cert generate IP_DO_PUPPET_SERVER
puppet resource service puppetserver ensure=running enable=true
puppet agent -t
puppet cert list
puppet cert sign IP_DO_PUPPET_AGENT
puppet agent -t