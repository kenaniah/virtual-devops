#!/bin/bash

# This script sets up and configures the puppetmaster 
# Only runs if this machine has the puppetmaster's IP address

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Don't do anything if we're not the puppetmaster
ifconfig | grep -q "$PUPPET_IP" || exit 1

# Install the puppet server
yum install puppet-server -y

# Start the puppetmaster service
puppet resource service puppetmaster ensure=running enable=true