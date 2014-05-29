# Copy over the puppet configs
rsync -v $SCRIPT_PATH/files/auth.conf /etc/puppet/auth.conf

# Perform a puppet run
puppet agent --test