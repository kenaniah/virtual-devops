#!/bin/bash

# This is the initial setup script that should be executed when the server
# is first provisioned. It will proceed to update pacakges and install the 
# software config stack.

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/scripts/config.sh

# Add cronic
cp $SCRIPT_PATH/files/cronic /usr/bin/cronic
chmod 777 /usr/bin/cronic

# Set the time zone
rm /etc/localtime -f && ln -s /usr/share/zoneinfo/$TZ /etc/localtime

# Install repositories
rpm -ihv http://mirror.steadfast.net/epel/6/x86_64/epel-release-6-8.noarch.rpm

# Point to the puppet host (if it doesn't already exist)
grep -q "puppet" /etc/hosts || echo "$PUPPET_IP puppet" >> /etc/hosts

# Determine if we are a puppet master or client
if [ `hostname` = "puppet" ]; then
	. $SCRIPT_PATH/scripts/puppet-master.sh
else
	. $SCRIPT_PATH/scripts/puppet-client.sh
fi

#rpm -ihv http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Install base packages
#yum install vim wget man htop puppet bind-utils mlocate yum-plugin-versionlock -y
#yum versionlock puppet facter

# Perform a full system update
yum update -y

# Copy over the puppet config files
#rsync -v $SCRIPT_PATH/files/auth.conf /etc/puppet/auth.conf
#rsync -v $SCRIPT_PATH/files/puppet.conf /etc/puppet/puppet.conf

# Set up the puppet master (if our IPs match)
#. $SCRIPT_PATH/scripts/puppetmaster.sh

# Perform the setup
#puppet agent --test --waitforcert 60

# Start the puppet client service
#puppet resource service puppet ensure=running enable=true
