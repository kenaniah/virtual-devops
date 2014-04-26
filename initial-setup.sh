#!/bin/bash

PUPPET_IP=192.241.234.84

# This is the initial setup script that should be executed when the server
# is first provisioned. It will proceed to update pacakges and install the 
# software config stack.

# Install repositories
rpm -ihv http://mirror.steadfast.net/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ihv http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Install base packages
yum install vim wget man htop -y

# Point to the puppet host (if it doesn't already exist)
grep -q "puppet" /etc/hosts || echo "$PUPPET_IP puppet" >> /etc/hosts

# Install software config
yum install puppet -y

yum update -y