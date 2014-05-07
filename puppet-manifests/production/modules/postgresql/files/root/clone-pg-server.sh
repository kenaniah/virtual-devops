#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

# Usage information
if [ $# -ne 1 ]
then
        echo "Usage: $0 <destination server>"
        echo
        echo "This script will take a base backup of the current server and restore it on the destination server as a read-only slave."
        exit 1
fi

# Generate physical copy of the DB
echo "Preparing the base backup file..."
su - postgres -c "pg_basebackup -x -Ft -z -D - > /tmp/pg_base_backup.tar.gz"

# Transfer to the destination server
echo "Transferring base backup to $1..."
scp /tmp/pg_base_backup.tar.gz root@$1:/var/lib/pgsql
rm /tmp/pg_base_backup.tar.gz -f

# Restoring clone
echo "Restoring clone on $1..." 
ssh $1 /root/restore-from-base-backup.sh