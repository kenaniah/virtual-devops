#!/bin/bash

# This file is being maintained by Puppet.
# DO NOT EDIT

##################################################
# Usage
##################################################
if [ $# -eq 0 ]
then
	echo "Usage: `basename $0` <backup_path> [<database>]..."
	exit 1
fi

##################################################
# Variable Definitions
##################################################
hour=$(date +%H)
day=$(date +%d)
time=$(date "+%FT%H:%M:%S")
dir=$(pwd)
skip=("mysql" "information_schema" "binlog" "performance_schema")

# Change to the backup directory and shift that param
cd ${1}
shift

##################################################
# Function Definitions
##################################################

# Performs a backup of all current databases.
# Takes a list of databases to back up as arguments
perform_mysql_backups() 
{
	
	# Determine the list of databases to be backed up
	if [ $# -eq 0 ]
	then
		dbs=$(echo "show databases" | mysql --skip-column-names)
	else
		dbs=$@
	fi
	
	for db in $dbs
	do
		
		# Skip system databases
		if [[ ${skip[*]} =~ "$db" ]]
		then
				continue
		fi
	
		# Perform the actual backup
		echo "$(date '+%D %H:%M:%S') - Backing up $db"
		touch backups/$db.$time.sql.gz
		mysqldump $db | gzip -c > backups/$db.$time.sql.gz
				
		# Link this backup as the most recent dump
		ln -s -f backups/$db.$time.sql.gz $db.sql.gz
		
	done
	
	# Remove any broken links after the fact
	find -L . -type l -exec unlink {} \;
	
}

# Performs rotation of backup files
function rotate_mysql_backups()
{
	
	echo "$(date '+%D %H:%M:%S') - Rotating backups"

	# Remove old backups
	find backups/ -mindepth 1 -mtime +7 -type f -exec rm -f {} \;
	find backups_monthly/ -mindepth 1 -mtime +31 -type f -exec rm -f {} \;
	find backups_yearly/ -mindepth 1 -mtime +366 -type f -exec rm -f {} \;
	
	for db in $dbs
	do
		
		# Skip system databases
		if [[ ${skip[*]} =~ "$db" ]]
		then
				continue
		fi
	
		if [ $hour -eq "00" ]
		then
			# Copy the last backup to the monthly folder
			cp backups/$db.$time.sql.gz backups_monthly/
			ln -s -f backups_monthly/$db.$time.sql.gz backups_monthly/$db.sql.gz
		fi
		
		if [ $hour -eq "00" -a $day -eq "01" ]
		then
			# Copy the last backup to the yearly folder
			cp backups/$db.$time.sql.gz backups_yearly/
			ln -s -f backups_yearly/$db.$time.sql.gz backups_yearly/$db.sql.gz
		fi
		
	done
	
}

# Rsyncs backup files. Depends on $dbs being defined.
function rsync_mysql_backups()
{
	
	# Rsync backups to NAS server
	echo "Rsync is not configured"
	
}

##################################################
# Main Script
##################################################

echo "$(date '+%D %H:%M:%S') - Backup started"

perform_mysql_backups $@

rotate_mysql_backups

rsync_mysql_backups

echo "$(date '+%D %H:%M:%S') - Backup completed"

# Revert to original directory
cd $dir