#!/bin/bash

# This script sets up and configures the puppetmaster 
# Only runs if this machine has the puppetmaster's IP address

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Don't do anything if we're not the puppetmaster
ifconfig | grep -q "$PUPPET_IP" || exit 1

# Install the puppet server
if [ ! -d /etc/puppet/manifests ]; then
	
	# Install packages
	yum install puppet-server httpd mod_passenger mod_ssl -y
	
	# Initialize paths
	mkdir -p /usr/share/puppet/rack/puppetmasterd/public
	mkdir -p /usr/share/puppet/rack/puppetmasterd/tmp
	chown -R puppet:puppet /usr/share/puppet/rack
	mkdir /var/run/passenger
	
	# Copy configs
	cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
	cp $SCRIPT_PATH/files/puppetmaster-vhost.conf /etc/httpd/conf.d/puppetmaster.conf
	
	# Initialize certs
	puppet cert generate puppet
	cp /var/lib/puppet/ssl/certs/puppet.pem /etc/pki/tls/certs/puppetmaster.pem
	cp /var/lib/puppet/ssl/private_keys/puppet.pem /etc/pki/tls/private/puppetmaster.key
	chmod 600 /etc/pki/tls/certs/puppetmaster.pem /etc/pki/tls/private/puppetmaster.key
	puppet cert clean puppet
		
fi

# Set up the autosign file
test -f /etc/puppet/autosign.conf || echo "$PUPPET_AUTOSIGN" > /etc/puppet/autosign.conf

# Update the manifest
rsync -rav $SCRIPT_PATH/puppet-manifests/ /etc/puppet/environments

# Update puppet modules
# puppet module install puppetlabs-apache

# Set up the service
puppet resource service puppetmaster ensure=stopped enable=false
puppet resource service httpd ensure=running enable=true
service httpd graceful