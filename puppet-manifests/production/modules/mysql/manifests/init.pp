class mysql {

	package { ["mysql", "mysql-server"]:
		ensure => installed
	}
	
	service { "mysqld":
		ensure => running,
		enable => true,
		require => Package["mysql-server"]
	}
	
	

}