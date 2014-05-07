#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

# Usage information
if [ $# -ne 2 ]
then
        echo "Usage: $0 <original_name> <new_name>"
        echo
        echo "This script will rename a database after disconnecting clients."
        exit 1
fi

# Close all connections to the requested database
echo "Closing connections to database $1..."
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$1'"

# Rename the database
echo "Renaming database $1 to $2..."
psql -c "ALTER DATABASE \"$1\" RENAME TO \"$2\""

