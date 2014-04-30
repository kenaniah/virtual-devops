node 'puppet' {
	# Install httpd mod_passenger mod_ssl
}

filebucket { "main":
	server => "puppet",
	path => false
}

File {
	backup => "main"
}