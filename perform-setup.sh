# Clone the base repo
yum install git -y && git clone https://github.com/kenaniah/virtual-devops.git /opt/virtual-devops

cd /opt/virtual-devops

# Ignore file modes and make shell scripts executable
git config core.filemode false

# Optioanlly checkout the branch we would like to use
test -n "$1" && git checkout "$1"

# Set all shell scripts to executable
chmod 744 scripts/*.sh

# Set the script path and load environment variables
SCRIPT_PATH=$(dirname `which $0`)
. $SCRIPT_PATH/config.sh

# Start the party
. $SCRIPT_PATH/setup.sh