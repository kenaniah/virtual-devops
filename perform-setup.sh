# Clone the base repo
yum install git -y && git clone https://github.com/kenaniah/digital-ocean-devops.git

cd digital-ocean-devops

# Ignore file modes and make shell scripts executable
git config core.filemode false
chmod 744 *.sh

cd ..

# Start the party
digital-ocean-devops/setup.sh