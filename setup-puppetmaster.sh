#!/bin/bash

# This script sets up and configures the puppetmaster 
# Only runs if this machine has the puppetmaster's IP address

SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Don't do anything if we're not the puppetmaster
ifconfig | grep -q "$PUPPET_IP" || exit 1

# Install the puppet server
if [ ! -d /etc/puppet/manifests ]; then
	
	# Install packages (dashboard requires MySQL for its backend)
	yum install puppet-server-3.4.3-1.el6 httpd mod_passenger mod_ssl puppet-dashboard mysql mysql-server -y
	yum versionlock puppet-server
	
	# Set up the autosign file
	test -f /etc/puppet/autosign.conf || echo "$PUPPET_AUTOSIGN" > /etc/puppet/autosign.conf
	
	# Initialize certs and stuff
	puppet resource service puppetmaster ensure=running enable=true
	
	# Initialize paths
	mkdir -p /usr/share/puppet/rack/puppetmasterd/public
	mkdir -p /usr/share/puppet/rack/puppetmasterd/tmp
	mkdir /var/run/passenger
	
	# Copy configs
	cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
	cp $SCRIPT_PATH/files/puppetmaster-vhost.conf /etc/httpd/conf.d/puppetmaster.conf
	cp $SCRIPT_PATH/files/dashboard-vhost.conf /etc/httpd/conf.d/dashboard.conf
	cp -f $SCRIPT_PATH/files/dashboard-settings.yml /usr/share/puppet-dashboard/config/settings.yml
	cp -f $SCRIPT_PATH/files/dashboard-database.yml /usr/share/puppet-dashboard/config/database.yml
	
	# Set up reporting
	mkdir -p $(puppet master --configprint libdir)/puppet/reports
	cp /usr/share/puppet-dashboard/ext/puppet/puppet_dashboard.rb $(puppet master --configprint libdir)/puppet/reports/
	
	# Update the DB password
	sed -i "/  password:/c\  password: $PUPPET_DASHBOARD_MYSQL_PASSWORD" /usr/share/puppet-dashboard/config/database.yml
	
	# Enforce permissions
	chown -R puppet:puppet /usr/share/puppet
	chown -R puppet-dashboard:puppet-dashboard /usr/share/puppet-dashboard
	
	# Set up MySQL
	puppet resource service mysqld ensure=running enable=true
	echo "CREATE DATABASE dashboard_production CHARACTER SET utf8;" | mysql
	echo "CREATE USER 'dashboard'@'localhost' IDENTIFIED BY '$PUPPET_DASHBOARD_MYSQL_PASSWORD';" | mysql
	echo "GRANT ALL PRIVILEGES ON dashboard_production.* TO 'dashboard'@'localhost'; FLUSH PRIVILEGES;" | mysql
	
	# Perform rake tasks
	cd /usr/share/puppet-dashboard
	sudo -u puppet-dashboard rake RAILS_ENV=production gems:refresh_specs
	sudo -u puppet-dashboard rake RAILS_ENV=production db:migrate
	sudo -u puppet-dashboard rake RAILS_ENV=production cert:create_key_pair
	sudo -u puppet-dashboard rake RAILS_ENV=production cert:request
	sudo -u puppet-dashboard rake RAILS_ENV=production cert:retrieve
		
	# Add provided classes to the dashboard
	sudo -u puppet-dashboard rake RAILS_ENV=production nodeclass:add name=postgresql
	sudo -u puppet-dashboard rake RAILS_ENV=production nodeclass:add name=php
	sudo -u puppet-dashboard rake RAILS_ENV=production nodeclass:add name=mysql
	sudo -u puppet-dashboard rake RAILS_ENV=production nodeclass:add name=mongodb
		
	cd -
	
fi

# Symlink the puppet manifests
ln -s /opt/virtual-devops/puppet-manifests /etc/puppet/environments

# Set up the service
puppet resource service puppetmaster ensure=stopped enable=false
puppet resource service httpd ensure=running enable=true
service httpd restart
puppet resource service puppet-dashboard-workers ensure=running enable=true

# Update ourself
puppet resource ini_setting "mysqld max_allowed_packet" ensure=present path=/etc/my.cnf section=mysqld setting=max_allowed_packet value=32M
service mysqld restart