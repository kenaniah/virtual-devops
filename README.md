DevOps Kickstarter
====================
To get rockin':

```bash
curl -sS https://raw.githubusercontent.com/kenaniah/virtual-devops/master/perform-setup.sh | bash
```

It's recommended that first run this on the puppet server, as it should be the first server provisioned. The puppet server must have a short hostname of "puppet".

How We Roll
----------------------
We assume this is the *first* command you run when provisioning a new server from a bare-bones CentOS image.

This git repository will be downloaded and installed in `/opt/virtual-devops`.

An entry for `puppet` will be added to `/etc/hosts`.

The puppet client in installed on all servers.

If the host's short name is `puppet`, the puppet master will be installed.
 * `/etc/puppet/environments` will be symlinked to `/opt/virtual-devops/puppet-manifests`
 * [Foreman](http://theforeman.org/learn_more.html) will be installed

Caveats
----------------------

 * The IP of the puppet server (`$PUPPET_IP` from `config.sh`) will be written to the hosts file
 * Servers aside from the puppet server will require manual signing of their certs for security (use `puppet cert sign <hostname>` or the foreman smart proxy on the puppetmaster)  
 * Setup appears to require a tty to be present. If you are using ssh, a tty may be faked via `ssh -t`
