#!/bin/bash

# This is the initial setup script that should be executed when the server
# is first provisioned. It will proceed to update pacakges and install the 
# software config stack.

# Add cronic
cp $SCRIPT_PATH/files/cronic /usr/bin/cronic
chmod 777 /usr/bin/cronic

# Set the time zone
rm /etc/localtime -f && ln -s /usr/share/zoneinfo/$TZ /etc/localtime

# Install repositories
rpm -ihv http://mirror.steadfast.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ihv http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Install base packages
yum -y install vim wget man htop bind-utils mlocate yum-plugin-versionlock

# Determine if we are a puppet master or client
if [ `hostname -s` = "puppet" ]; then
	# Point to the puppet host (if it doesn't already exist)
	grep -q "puppet" /etc/hosts || echo "127.0.0.1 puppet.$DOMAIN puppet" >> /etc/hosts
	. $SCRIPT_PATH/scripts/puppet-master.sh
else
	# Point to the puppet host (if it doesn't already exist)
	grep -q "puppet" /etc/hosts || echo "$PUPPET_IP puppet.$DOMAIN puppet" >> /etc/hosts
fi

# Configure puppet clients
. $SCRIPT_PATH/scripts/puppet-client.sh

# Perform a full system update
yum -y update

# Copy over the puppet config files
#rsync -v $SCRIPT_PATH/files/puppet.conf /etc/puppet/puppet.conf

# Set up the puppet master (if our IPs match)
#. $SCRIPT_PATH/scripts/puppetmaster.sh

# Perform the setup
#puppet agent --test --waitforcert 60

# Start the puppet client service
#puppet resource service puppet ensure=running enable=true
