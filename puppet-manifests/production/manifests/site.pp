node 'puppet' {
	# Install httpd mod_passenger mod_ssl
}

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