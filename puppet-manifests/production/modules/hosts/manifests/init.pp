# Automatically adds new entries in the hosts file
# for each new server managed by Puppet
# (Servers may be excluded by setting the ignore attribute)
class hosts {
	
	$ignore = false
	$ip = $::ipaddress_eth1
	$host_aliases = [ $::hostname ]
	
	$host_tag = $hosts::ignore ? {
		true => 'Excluded',
		default => 'Included'
	}
		
	# Publish my host definition for external nodes
	@@host { $::fqdn:
		ip	=> $hosts::ip,
		host_aliases => $hosts::host_aliases,
		tag => $host_tag
	}
	
	# Collect external host definitions
	Host <<| tag == "Included" |>> {
		ensure => present
	} ->
	
	# Set up the localhost
	host {'localhost':
		name => $::fqdn,
		ip => '127.0.0.1',
		host_aliases => [ $::hostname, 'localhost', 'localhost.localdomain' ],
		tag => 'Included'
	}
	
	# Purge other host definitions
	resources {'host':
		purge => true
	}
	
}