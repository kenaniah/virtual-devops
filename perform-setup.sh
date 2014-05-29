# Set the script path
SCRIPT_PATH=$(dirname `which $0`)

# Load environment variables
. $SCRIPT_PATH/scripts/config.sh

# Start the party
. $SCRIPT_PATH/scripts/setup.sh