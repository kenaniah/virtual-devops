# Initialize the puppet master (starting the service initializes the certificates)
yum -y install puppet-server
service puppetmaster start
service puppetmaster stop

# Install the foreman installer
yum -y install http://yum.theforeman.org/releases/1.5/el6/x86_64/foreman-release.rpm
yum -y install foreman-installer
foreman-installer

# Symlink the puppet manifests
rm -rf /etc/puppet/environments
ln -s /opt/virtual-devops/puppet-manifests /etc/puppet/environments
rm -f /etc/puppet/manifests/site.pp
ln -s /etc/puppet/environments/production/manifests/site.pp /etc/puppet/manifests/site.pp

# Import existing classes
foreman-rake puppet:import:puppet_classes[batch]
#foreman-rake puppet:rdoc:generate

# Install puppetdb
yum -y install puppetdb-terminus

# Write the puppetdb config file
echo -e "[main]\nserver = puppet\nport = 8081\n" > /etc/puppet/puppetdb.conf

# Write the routes file
cp $SCRIPT_PATH/files/routes.yaml /etc/puppet/

#rm -rf $SCRIPT_PATH/puppet-manifests/production/modules/*
#puppet module install puppetlabs-puppetdb
#puppet apply -e "include puppetdb"
#cd $SCRIPT_PATH
#git add .
#git reset --hard HEAD
#cd -
