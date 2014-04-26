DevOps Kickstarter
====================
To get rockin':

```bash
# Installs git and clones this repo
yum install git -y && git clone https://github.com/kenaniah/digital-ocean-devops.git

cd digital-ocean-devops

# Ignore file modes and make shell scripts executable
git config core.filemode false
chmod 744 *.sh

# Update this file to match your environment
vi config.sh 

cd ..

# Start the party
digital-ocean-devops/initial-setup.sh
```
