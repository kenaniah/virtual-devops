class php {

	Package {
		ensure => installed,
		require => Ini_setting["remi php 5.5"]
	}

	exec { "remi yum repo":
		command => "rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm",
		creates => "/etc/yum.repos.d/remi.repo"
	}
	
	ini_setting { "remi php 5.5":
		ensure => present,
		path => "/etc/yum.repos.d/remi.repo",
		section => "remi-php55",
		setting => "enabled",
		value => 1,
		require => Exec["remi yum repo"]
	}

	package { [
		"gcc", 
		"php",
		"php-pdo",
		"php-pgsql",
		"php-mysqlnd",
		"php-pecl-xdebug"
	  ]: 
	}

	/*
	#$php_version = "5.3.6"
	package {
		"gcc":			ensure => installed;
		"php":			ensure => installed,
						require => Yumrepo["remi"];
		"php-cli":		ensure => installed,
						require => Yumrepo["remi"];
		"php-gd":		ensure => installed,
						require => Yumrepo["remi"];
		"php-pdo":		ensure => installed,
						require => Yumrepo["remi"];
		"php-pgsql":		ensure => installed,
						require => Yumrepo["remi"];
		"php-mysqlnd":		ensure => installed,
						require => Yumrepo["remi"];
		"php-bcmath":	ensure => installed,
						require => Yumrepo["remi"];
		"php-mcrypt":	ensure => installed,
						require => Yumrepo["remi"];
		"php-mbstring":	ensure => installed,
						require => Yumrepo["remi"];
		"php-xml":		ensure => installed,
						require => Yumrepo["remi"];
		"php-ldap":		ensure => installed,
						require => Yumrepo["remi"];
		"php-pecl-xdebug":	ensure => installed,
						require => Yumrepo["remi"];
		"php-pear-Spreadsheet-Excel-Writer":	
						ensure => installed,
						require => Yumrepo["remi"];
		"php-swift-Swift":	ensure => installed,
						require => Yumrepo["remi"];
		"mod_suphp":	ensure => installed,
						require	=> [
								Yumrepo["rpmforge"],
								Package["php"],
								];
	}
	file {
		
		
		"/etc/php.ini":
		mode	=> 0644,
		owner	=> root,
		group	=> root,
		content	=> template("php/php.ini.erb"),
		require	=> Package["php"];
	
		"/etc/suphp.conf":
		mode	=> 0644,
		owner	=> root,
		group	=> root,
		source	=> [
			"puppet:///modules/php/etc/suphp.conf.$hostname",
			"puppet:///modules/php/etc/suphp.conf",
		],
		require	=> Package["mod_suphp"];
		
		"/etc/httpd/conf.d/suphp.conf":
		mode	=> 0644,
		owner	=> root,
		group	=> root,
		source	=> [
			"puppet:///modules/php/etc/httpd/conf.d/suphp.conf.$hostname",
			"puppet:///modules/php/etc/httpd/conf.d/suphp.conf",
		],
		require	=> Package["mod_suphp"];

	} #file
	
	*/
}
