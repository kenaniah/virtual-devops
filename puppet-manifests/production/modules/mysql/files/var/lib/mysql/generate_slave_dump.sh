#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

echo "Now creating slave dump file...";
mysqldump --all-databases --add-drop-database --extended-insert --quick --routines --master-data | gzip > slave.sql.gz
echo "Dumpfile slave.sql.gz created";
