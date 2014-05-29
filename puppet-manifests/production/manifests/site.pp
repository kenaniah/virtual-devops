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

# Hostfile management
include hosts
