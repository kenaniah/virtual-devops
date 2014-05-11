DevOps Kickstarter
====================
To get rockin':

```bash
curl -sS https://raw.githubusercontent.com/kenaniah/virtual-devops/master/perform-setup.sh | bash
```

How We Roll
----------------------
We assume this is the *first* command you run when provisioning a new server from a bare-bones CentOS image.

This git repository will be downloaded and installed in `/opt/virtual-devops`.

If the host's IP matches the IP of the puppet server (`$PUPPET_IP` from `config.sh`), the puppet master will be installed and the environments directory symlinked to `/opt/virtual-devops/puppet-manifests`.

Caveats
----------------------

 * The puppet server must have the hostname of `puppet`
 * The location of the puppet host is statically set in `/etc/hosts` based on `$PUPPET_IP`
 * Puppet dashboard setup uses `sudo`, which requires a tty to be present. If you are using ssh, a tty may be faked via `ssh -t`
