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

class {'hosts':

}

Package {
	allow_virtual => true
}