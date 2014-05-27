# Don't do anything if we're not the puppetmaster
test `hostname` = "puppet" || return 1

# Install the foreman installer
yum -y install http://yum.theforeman.org/releases/1.5/el6/x86_64/foreman-release.rpm
yum -y install foreman-installer

