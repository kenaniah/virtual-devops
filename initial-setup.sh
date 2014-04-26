#!/bin/bash

# This is the initial setup script that should be executed when the server
# is first provisioned. It will proceed to update pacakges and install the 
# software config stack.

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Install repositories
rpm -ihv http://mirror.steadfast.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ihv http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Install base packages
yum install vim wget man htop puppet -y

# Point to the puppet host (if it doesn't already exist)
grep -q "puppet" /etc/hosts || echo "$PUPPET_IP puppet" >> /etc/hosts

# Perform a full system update
yum update -y

# Set up the puppet master (if our IPs match)
. $SCRIPT_PATH/setup-puppetmaster.sh

# Perform the setup
puppet agent --onetime --no-daemonize -v

# Start the puppet client service
puppet resource service puppet ensure=running enable=true
