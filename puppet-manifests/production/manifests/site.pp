filebucket { "main":
	server => "puppet",
	path => false
}

Exec {
	path => $path
}

File {
	backup => "main"
}

Package {
	allow_virtual => true
}

# Use the internal IP address to refer to other hosts
class {'hosts':
	ip => $::ipaddress_eth1 
}