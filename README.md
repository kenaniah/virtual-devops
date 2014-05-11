DevOps Kickstarter
====================
To get rockin':

```bash
curl -sS https://raw.githubusercontent.com/kenaniah/virtual-devops/master/perform-setup.sh | bash
```

It's recommended that first run this on the puppet server, as it should be the first server provisioned. Not required, but you should probably name that host "puppet".

How We Roll
----------------------
We assume this is the *first* command you run when provisioning a new server from a bare-bones CentOS image.

This git repository will be downloaded and installed in `/opt/virtual-devops`.

An entry for `puppet` will be added to `/etc/hosts`.

The puppet client in installed on all servers.

If the host's IP matches the IP of the puppet server (`$PUPPET_IP` from `config.sh`), the puppet master will be installed.
 * `/etc/puppet/environments` will be symlinked to `/opt/virtual-devops/puppet-manifests`
 * The puppet dashboard will be installed
    * Apache, MySQL, mod_passenger, and mod_ssl are installed as dependencies
    * Apache will be configured to vhost the puppet dashboard via mod_passenger at `https://$PUPPET_IP:3000`
    * MySQL's `max_allowed_packet` will be set to 32MB


Caveats
----------------------

 * The puppet server must have the hostname of `puppet`
 * The location of the puppet host is statically set in `/etc/hosts` based on `$PUPPET_IP`
 * Puppet dashboard setup uses `sudo`, which requires a tty to be present. If you are using ssh, a tty may be faked via `ssh -t`
