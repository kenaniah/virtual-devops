class mongodb {
	
	file {
		"/etc/yum.repos.d/mongodb.repo":
			ensure => file,
			source => [ "puppet:///modules/mongodb/etc/yum.repos.d/mongodb.repo" ]
	}
	
	package { ["mongo-10gen", "mongo-10gen-server"]:
		ensure => present,
		require => File["/etc/yum.repos.d/mongodb.repo"]
	}
	
	service { "mongod":
		ensure => running,
		enable => true
	}
	
}