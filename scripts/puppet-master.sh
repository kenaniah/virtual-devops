# Install the foreman installer
yum -y update
yum -y install http://yum.theforeman.org/releases/1.5/el6/x86_64/foreman-release.rpm
yum -y install foreman-installer
foreman-installer --puppet-server=false --puppet-agent=false

# Symlink the puppet manifests
rm -rf /etc/puppet/environments
ln -s /opt/virtual-devops/puppet-manifests /etc/puppet/environments
rm -f /etc/puppet/manifests/site.pp
ln -s /etc/puppet/environments/production/manifests/site.php /etc/puppet/manifests/site.pp

# Import existing classes
#foreman-rake puppet:import:puppet_classes
#foreman-rake puppet:rdoc:generate