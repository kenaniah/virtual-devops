#!/bin/bash

# This script sets up and configures the puppetmaster 
# Only runs if this machine has the puppetmaster's IP address

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Don't do anything if we're not the puppetmaster
ifconfig | grep -q "$PUPPET_IP" || exit 1

# Install the puppet server
yum install puppet-server -y

# Set up the autosign file
test -f /etc/puppet/autosign.conf || echo "$PUPPET_AUTOSIGN" > /etc/puppet/autosign.conf

# Symlink to the manifest
rmdir /etc/puppet/manifests && ln -s $SCRIPT_PATH/puppet-manifests /etc/puppet/manifests

# Start the puppetmaster service
puppet resource service puppetmaster ensure=running enable=true