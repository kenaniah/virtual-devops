# Automatically adds new entries in the hosts file
# for each new server managed by Puppet
# (Servers may be excluded by setting the ignore attribute)
class hosts {
	
	$ignore = false
	$ip = $::ipaddress
	$host_aliases = [ $::hostname ]
	
	$host_tag = $hosts::ignore ? {
		true => 'Excluded',
		default => 'Included'
	}
	
	@@host { $::fqdn:
		ip	=> $hosts::ip,
		host_aliases => $hosts::host_aliases,
		tag => $host_tag
	}
	
	Host <<| tag == "Included" |>> {
		ensure => present
	}
	
}