# Install the puppet labs RPM
# rpm -ihv http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm

# Copy over the puppet configs
rsync -v $SCRIPT_PATH/files/auth.conf /etc/puppet/auth.conf
