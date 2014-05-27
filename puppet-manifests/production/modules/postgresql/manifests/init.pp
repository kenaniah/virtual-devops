class postgresql($major = 9, $minor = 3, $shared_buffers = "500MB", $effective_cache_size = "1GB") {

	$os = inline_template("<%= operatingsystem.downcase %>")
	$family = inline_template("<%= osfamily.downcase %>")

	# Version information 
	$postgres_client  = "postgresql${major}${minor}"
	$postgres_server  = "postgresql${major}${minor}-server"
	$postgres_contrib = "postgresql${major}${minor}-contrib"
	$package = "pgdg-${os}${major}${minor}"
	
	# Defaults
	Ini_setting {
		ensure => present,
		path => "/var/lib/pgsql/${major}.${minor}/data/postgresql.conf",
		section => "",
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ],
		notify => Service["postgresql-${major}.${minor}"]
	}
	
	File {
		owner => "postgres",
		group => "postgres",
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ]
	}
	
	exec {
		"install-pgdg-${major}${minor}":
			command => "wget -nd -r -l 1 http://yum.postgresql.org/${major}.${minor}/${family}/rhel-${operatingsystemmajrelease}-${hardwareisa}/ -A 'pgdg*${os}*' && ls -F pgdg-${os}* | head --lines=-1 | xargs rm ; rpm -ivh pgdg-${os}* && rm -f pgdg-${os}*;",
			creates => "/etc/yum.repos.d/pgdg-${major}${minor}-${os}.repo";
		"init-db-${major}.${minor}":
			command => "service postgresql-${major}.${minor} initdb",
			creates => "/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf",
			require => Package[$postgres_server]
	}
	
	package { [$postgres_client, $postgres_server, $postgres_contrib]:  
		ensure => installed, require => Exec["install-pgdg-${major}${minor}"];
	}

	service { "postgresql-${major}.${minor}":
		ensure => running,
		enable => true,
		hasstatus => true,
		hasrestart => true,
		require => [ Package[$postgres_server], Exec["init-db-${major}.${minor}"] ],
		subscribe => File["/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf"]
	}
	
	file { 
		"/var/log/postgresql-${major}.${minor}":
			ensure => directory,
			mode => 0700;
		 "/etc/profile.d/postgresql.sh":
			ensure => file,
			content => template("postgresql/profile.sh.erb"),
			owner => "root",
			group => "root",
			mode => 0644;
		"/etc/sysconfig/pgsql/postgresql-${major}.${minor}":
			ensure => file,
			content => template("postgresql/sysconfig.erb"),
			owner => "root",
			group => "root",
			mode => 0644;
		"/var/lib/pgsql/${major}.${minor}/data/pg_hba.conf":
			ensure => file,
			source => [ "puppet:///modules/postgresql/var/lib/pgsql/data/pg_hba.conf" ],
			mode => 0600;
		"/var/lib/pgsql/backup.sh":
			ensure => file,
			source => [ "puppet:///modules/postgresql/var/lib/pgsql/backup.sh" ],
			mode => 1744;
		"/var/lib/pgsql/restore.sh":
			ensure => file,
			content => template("postgresql/restore.sh.erb"),
			mode => 1744;
		"/var/lib/pgsql/rename.sh":
			ensure => file,
			source	=> [ "puppet:///modules/postgresql/var/lib/pgsql/rename.sh" ],
			mode => 1744;
		"/var/lib/pgsql/analyze.sh":
			ensure => file,
			source	=> [ "puppet:///modules/postgresql/var/lib/pgsql/analyze.sh" ],
			mode => 1744;
		"/var/lib/pgsql/${major}.${minor}/backups_monthly":
			ensure => directory,
			mode => 0700;
		"/var/lib/pgsql/${major}.${minor}/backups_yearly":
			ensure => directory,
			mode => 0700;
		"/root/clone-pg-server.sh":
			ensure => file,
			source	=> [ "puppet:///modules/postgresql/root/clone-pg-server.sh" ],
			mode => 1700;
		"/root/restore-from-base-backup.sh":
			ensure => file,
			content => template("postgresql/restore-from-base-backup.sh.erb"),
			mode => 1700;
	}
	
	ini_setting { 
		"postgresql ini listen_addresses":
			setting => "listen_addresses",
			value => "'*'";
		"postgresql ini max_connections":
			setting => "max_connections",
			value => 200;
		"postgresql ini port":
			setting => "port",
			value => "54${major}${minor}";
		"postgresql ini shared_buffers":
			setting => "shared_buffers",
			value => "${shared_buffers}";
		"postgresql ini work_mem":
			setting => "work_mem",
			value => "16MB";
		"postgresql ini maintenance_work_mem":
			setting => "maintenance_work_mem",
			value => "128MB";
		"postgresql ini effective_cache_size":
			setting => "effective_cache_size",
			value => "${effective_cache_size}";
		"postgresql ini default_statistics_target":
			setting => "default_statistics_target",
			value => 1000;
		"postgresql ini checkpoint_segments":
			setting => "checkpoint_segments",
			value => 64;
		"postgresql ini checkpoint_completion_target":
			setting => "checkpoint_completion_target",
			value => 0.75;
		"postgresql ini log_directory":
			setting => "log_directory",
			value => "'/var/log/postgresql-${major}.${minor}'";
		"postgresql ini log_filename":
			setting => "log_filename",
			value => "'postgresql-%Y-%m-%d_%H%M%S.log'";
		"postgresql ini log_rotation_age":
			setting => "log_rotation_age",
			value => 0;
		"postgresql ini log_rotation_size":
			setting => "log_rotation_size",
			value => "64MB";
		"postgresql ini log_error_verbosity":
			setting => "log_error_verbosity",
			value => "verbose";
		"postgresql ini log_hostname":
			setting => "log_hostname",
			value => "on";
		"postgresql ini log_line_prefix":
			setting => "log_line_prefix",
			value => "'%m - [%d] {%v} (%s) '";
		"postgresql ini track_io_timing":
			setting => "track_io_timing",
			value => "on";
		"postgresql ini track_functions":
			setting => "track_functions",
			value => "all";
		}
	
	cron { "postgresql backup":
		command => "cronic su - postgres -c \"/var/lib/pgsql/backup.sh\"",
		hour => $hostname ? {
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