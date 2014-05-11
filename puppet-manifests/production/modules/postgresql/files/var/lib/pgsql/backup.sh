#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

##################################################
# Usage: `basename $0` [<database>]...
##################################################

# Variable Definitions
VERSION=`psql --version | rev | cut -d " " -f1 | rev | awk -F \. {'print $1 "." $2'}`
hour=$(date +%H)
day=$(date +%d)
time=$(date "+%FT%H:%M:%S")
dir=$(pwd)
dump_args=()
args=()

# Change to the versioned directory
cd ~/$VERSION

# Consume other arguments
while test $# -gt 0; do
	case "$1" in
		*)
			args=("${args[@]}" "$1")		
			shift
			;;		
	esac
done

# Reset the input args
set -- "${args[@]}"

##################################################
# Function Definitions
##################################################

# Performs a backup of all current databases.
# Takes a list of databases to back up as arguments
perform_postgres_backups() 
{
	
	# Determine the list of databases to be backed up
	if [ $# -eq 0 ]
	then
		# Exclude databases that are suffixed with an underscore
		dbs=$(psql -Altc "SELECT datname FROM pg_database WHERE NOT datistemplate AND datallowconn AND datname != 'postgres' AND datname NOT LIKE '%\_';")
	else
		dbs=$@
	fi
	
	for db in $dbs
	do
	
		# Perform the actual backup (excluding the temp schema if it exists)
		echo "$(date '+%D %H:%M:%S') - Backing up $db"
		touch backups/$db.$time.dump
		pg_dump -Fc -N temp -f backups/$db.$time.dump $dump_args $db
		
		# Link this backup as the most recent dump
		ln -s -f backups/$db.$time.dump $db.dump
		
	done
	
	# Remove any broken links after the fact
	find -L . -type l -exec unlink {} \;
	
}

# Performs rotation of backup files
function rotate_postgres_backups()
{
	
	echo "$(date '+%D %H:%M:%S') - Rotating backups"

	# Remove old backups
	find backups/ -mindepth 1 -mtime +2 -type f -exec rm -f {} \;
	find backups_monthly/ -mindepth 1 -mtime +31 -type f -exec rm -f {} \;
	find backups_yearly/ -mindepth 1 -mtime +366 -type f -exec rm -f {} \;
	
	for db in $dbs
	do
	
		if [ $hour -eq "00" ]
		then
			# Copy the last backup to the monthly folder
			cp backups/$db.$time.dump backups_monthly/
			ln -s -f backups_monthly/$db.$time.dump backups_monthly/$db.dump
		fi
		
		if [ $hour -eq "00" -a $day -eq "01" ]
		then
			# Copy the last backup to the yearly folder
			cp backups/$db.$time.dump backups_yearly/
			ln -s -f backups_yearly/$db.$time.dump backups_yearly/$db.dump
		fi
		
	done
	
}

# Rsyncs backup files. Depends on $dbs being defined.
function rsync_postgres_backups()
{
	
	# Rsync backups to NAS server
	echo "Rsync is not configured"
			
}

##################################################
# Main Script
##################################################

echo "$(date '+%D %H:%M:%S') - Backup started"

perform_postgres_backups $@

rotate_postgres_backups

rsync_postgres_backups

echo "$(date '+%D %H:%M:%S') - Backup completed"

# Revert to original directory
cd $dir