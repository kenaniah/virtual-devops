class php {

	Package {
		ensure => installed,
		require => Ini_setting["remi php 5.5"]
	}

	exec { "remi yum repo":
		command => "rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm",
		creates => "/etc/yum.repos.d/remi.repo"
	}
	
	exec { "rpmforge yum repo":
		command => "rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm",
		creates => "/etc/yum.repos.d/rpmforge.repo"
	}
	
	ini_setting { "remi base":
		ensure => present,
		path => "/etc/yum.repos.d/remi.repo",
		section => "remi",
		setting => "enabled",
		value => 1,
		require => Exec["remi yum repo"]
	}
	
	ini_setting { "remi php 5.5":
		ensure => present,
		path => "/etc/yum.repos.d/remi.repo",
		section => "remi-php55",
		setting => "enabled",
		value => 1,
		require => Exec["remi yum repo"]
	}
	
	file { "/etc/php.d/custom.ini":
		ensure => file,
		source => [ "puppet:///modules/php/etc/php.d/custom.ini" ],
		require => Package["php"]
	}

	package { [
		"gcc",
		"php",
		"php-common",
		"php-cli",
		"php-gd",
		"php-intl",
		# "php-magickwand",
		"php-markdown",
		"php-mbstring",
		"php-mysqlnd",
		"php-pdo",
		"php-pear",
		"php-pecl-gmagick",
		# "php-pecl-imagick",
		"php-pecl-memcached",
		"php-pecl-mongo",
		"php-pecl-oauth",
		"php-pecl-xdebug",
		"php-pgsql",
		"php-swift-Swift",
		"php-tidy",
		"php-xml",
		"php-zts"
	  ]: 
	}
	
	package { "mod_suphp":
		require => Exec["rpmforge yum repo"]
	}
	
	ini_setting { "suphp ini umask":
		ensure => present,
		path => "/etc/suphp.conf",
		section => "global",
		setting => "umask",
		value => "0022",
		require => Package["mod_suphp"]
	}
	
}
