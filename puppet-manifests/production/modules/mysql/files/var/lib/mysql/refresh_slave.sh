#!/bin/sh

# This file is being maintained by Puppet.
# DO NOT EDIT

if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` <slave_hostname>"
	exit 1
fi

skip=("mysql" "information_schema" "binlog" "performance_schema")

echo "$(date '+%D %H:%M:%S') - Backing up mysql databases"

ssh $1 "mysql -e 'STOP SLAVE'";
SQL=$(mysqldump "" --master-data 2> /dev/null | awk 'END { print }')

ssh $1 "mysql -e \"${SQL}\""

##
# Get a list of the databases to be exported.
##

dbs=$(echo "show databases" | mysql --skip-column-names)

for db in ${dbs};
do
	# Skip system databases
	if [[ ${skip[*]} =~ "$db" ]]
	then
		continue
	fi

	echo "$(date '+%D %H:%M:%S') - Backing up ${db}...";

	mysqldump $db | gzip -c > ${db}-slave.sql.gz
	scp ${db}-slave.sql.gz root@${1}:/root/
	rm -f ${db}-slave.sql.gz

	ssh $1 "gunzip -c ${db}-slave.sql.gz | mysql ${db}; rm -f ${db}-slave.sql.gz" &

done

echo "$(date '+%D %H:%M:%S') - Waiting for database restores to complete"
wait

echo "$(date '+%D %H:%M:%S') - Starting slave"
ssh $1 "mysql -e 'START SLAVE;'"
ssh $1 "mysql -e 'SHOW SLAVE STATUS;'"
