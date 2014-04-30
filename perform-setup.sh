# Clone the base repo
yum install git -y && git clone https://github.com/kenaniah/virtual-devops.git

cd virtual-devops

# Ignore file modes and make shell scripts executable
git config core.filemode false

# Optioanlly checkout the branch we would like to use
test -n "$1" && git checkout "$1"

# Set all shell scripts to executable
chmod 744 *.sh

cd ..

# Start the party
virtual-devops/setup.sh
