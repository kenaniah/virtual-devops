# Copy over the puppet configs
rsync -v $SCRIPT_PATH/files/auth.conf /etc/puppet/auth.conf
rsync -v $SCRIPT_PATH/files/puppet.conf /etc/puppet/puppet.conf

# Perform a puppet run
puppet agent --test