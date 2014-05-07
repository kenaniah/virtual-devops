#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

# Determine the list of databases to be analyzed
if [ $# -eq 0 ]
then
	# All connectable databases
	dbs=$(psql -Altc "SELECT datname FROM pg_database WHERE datallowconn;")
else
	dbs=$@
fi

if [ `psql -t -c "SELECT pg_is_in_recovery()"` = "f" ]; then

	for db in $dbs
	do
	
		# Vacuum analyze the DB
		psql $db -c "VACUUM ANALYZE"
		
	done

fi