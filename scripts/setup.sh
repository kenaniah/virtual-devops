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
yum -y install vim wget man htop bind-utils mlocate yum-plugin-versionlock puppet

# Determine if we are a puppet master or client
if [ `hostname -s` = "puppet" ]; then
	# Point to the puppet host (if it doesn't already exist)
	grep -q "puppet" /etc/hosts || echo "127.0.0.1 puppet" >> /etc/hosts
	. $SCRIPT_PATH/scripts/puppet-master.sh
else
	# Point to the puppet host (if it doesn't already exist)
	grep -q "puppet" /etc/hosts || echo "$PUPPET_IP puppet" >> /etc/hosts
	# Point to self as well
	grep -q `hostname` /etc/hosts || echo "127.0.0.1 `hostname` `hostname -s`" >> /etc/hosts
fi

# Configure puppet clients
. $SCRIPT_PATH/scripts/puppet-client.sh

# Perform a full system update
yum -y update
