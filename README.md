DevOps Kickstarter
====================
To get rockin':

```bash
curl -sS https://raw.githubusercontent.com/kenaniah/virtual-devops/master/perform-setup.sh | bash
```

Caveats
----------------------

 * Puppet dashboard setup uses `sudo`, which requires a tty to be present. If you are using ssh, a tty may be faked via `ssh -t`.
 * The puppet server must have the hostname of `puppet`. 
 * The location of the puppet host is statically set in `/etc/hosts` based on `$PUPPET_IP`

