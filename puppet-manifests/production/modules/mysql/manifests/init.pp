class mysql {

	$backup_path = "/var/lib/mysql-backups"

	File {
		owner => "mysql",
		group => "mysql",
		require => Package["mysql-server"]
	}

	package { ["mysql", "mysql-server"]:
		ensure => installed
	}
	
	service { "mysqld":
		ensure => running,
		enable => true,
		require => Package["mysql-server"]
	}
	
	file {
		"${backup_path}":
			ensure => directory,
			mode => 0700;
		"${backup_path}/backups":
			ensure => directory,
			mode => 0700;
		"${backup_path}/backups_monthly":
			ensure => directory,
			mode => 0700;
		"${backup_path}/backups_yearly":
			ensure => directory,
			mode => 0700;
		"/var/lib/mysql/backup.sh":
			ensure => file,
			source => [ "puppet:///modules/mysql/var/lib/mysql/backup.sh" ],
			mode => 1744;
		"/var/lib/mysql/refresh_slave.sh":
			ensure => file,
			source => [ "puppet:///modules/mysql/var/lib/mysql/refresh_slave.sh" ],
			mode => 1744;
		"/var/lib/mysql/generate_slave_dump.sh":
			ensure => file,
			source => [ "puppet:///modules/mysql/var/lib/mysql/generate_slave_dump.sh" ],
			mode => 1744;
	}
	
	cron { "mysql backup":
		command => "cronic su - mysql -c \"/var/lib/mysql/backup.sh ${backup_path}\"",
		hour => $hostname ? {
			default => "*"
		},
		minute => 0,
		require => File["/var/lib/mysql/backup.sh"]
	}

}