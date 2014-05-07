class postgresql($major = '9', $minor = '3') {

	$os = inline_template("<%= operatingsystem.downcase %>")
	$family = inline_template("<%= osfamily.downcase %>")

	# Version information 
	$postgres_client  = "postgresql${major}${minor}"
	$postgres_server  = "postgresql${major}${minor}-server"
	$postgres_contrib = "postgresql${major}${minor}-contrib"
	$package = "pgdg-${os}${major}${minor}"
	
	exec {
		"install-pgdg-${major}${minor}":
			command => "wget -nd -r -l 1 http://yum.postgresql.org/${major}.${minor}/${family}/rhel-${lsbmajdistrelease}-${hardwareisa}/ -A 'pgdg*${os}*' && ls -F pgdg-${os}* | head --lines=-1 | xargs rm ; rpm -ivh pgdg-${os}* && rm -f pgdg-${os}*;",
			creates => "/etc/yum.repos.d/pgdg-${major}${minor}-${os}.repo"
	}
	
	exec {
		"init-db-${major}.${minor}":
			command => "service postgresql-${major}.${minor} initdb",
			creates => "/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf",
			require => Package[$postgres_server]
	}
	
	package {
		$postgres_client:   ensure => installed, require => Exec["install-pgdg-${major}${minor}"];
		$postgres_server:   ensure => installed, require => Exec["install-pgdg-${major}${minor}"];
		$postgres_contrib:  ensure => installed, require => Exec["install-pgdg-${major}${minor}"];
	}

	service { "postgresql-${major}.${minor}":
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ],
		subscribe => File["/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf"]
	}
	
	file { "/etc/profile.d/postgresql.sh":
		ensure => file,
		content => template("postgresql/profile.sh.erb"),
		owner => "root",
		group => "root",
		mode => 0644,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf":
		ensure => file,
		source => [ "puppet:///modules/postgresql/var/lib/pgsql/data/pg_hba.conf" ],
		owner => "postgres",
		group => "postgres",
		mode => 0600,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/backup.sh":
		ensure => file,
		source => [ "puppet:///modules/postgresql/var/lib/pgsql/backup.sh" ],
		owner => "postgres",
		group => "postgres",
		mode => 1744,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/restore.sh":
		ensure => file,
		content => template("postgresql/restore.sh.erb"),
		owner => "postgres",
		group => "postgres",
		mode => 1744,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/rename.sh":
		ensure => file,
		source	=> [ "puppet:///modules/postgresql/var/lib/pgsql/rename.sh" ],
		owner => "postgres",
		group => "postgres",
		mode => 1744,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/analyze.sh":
		ensure => file,
		source	=> [ "puppet:///modules/postgresql/var/lib/pgsql/analyze.sh" ],
		owner => "postgres",
		group => "postgres",
		mode => 1744,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/${major}.${minor}/backups_monthly":
		ensure => directory,
		owner => "postgres",
		group => "postgres",
		mode => 0700,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/var/lib/pgsql/${major}.${minor}/backups_yearly":
		ensure => directory,
		owner => "postgres",
		group => "postgres",
		mode => 0700,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/root/clone-pg-server.sh":
		ensure => file,
		source	=> [ "puppet:///modules/postgresql/root/clone-pg-server.sh" ],
		owner => "postgres",
		group => "postgres",
		mode => 1700,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	file { "/root/restore-from-base-backup.sh":
		ensure => file,
		content => template("postgresql/restore-from-base-backup.sh.erb"),
		owner => "postgres",
		group => "postgres",
		mode => 1700,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	cron { "postgresql ${major}.${minor} backup":
		command => "cronic su - postgres -c \"/var/lib/pgsql/backup.sh ${major}.${minor}\"",
		hour => $hostname ? {
			"dbdev" => 0,
			"virt2" => 1,
			default => "*"
		},
		minute => 0,
		require => File["/var/lib/pgsql/backup.sh"]
	}
	
	cron { "postgresql analyze":
		command => "cronic su - postgres -c \"/var/lib/pgsql/analyze.sh\"",
		hour => 5,
		minute => 0,
		require => File["/var/lib/pgsql/analyze.sh"]
	}

}