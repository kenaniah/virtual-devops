node 'puppet' {
	class {'apache':
		purge_configs: false 
	}
}