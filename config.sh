#!/bin/bash

# Defines config options used by other scripts

# Static IP address of the puppet server (will be set in /etc/hosts)
PUPPET_IP=192.241.234.84

# Hosts that puppet will automatically sign certs for
PUPPET_AUTOSIGN=*

# Timezone of the server
TZ=America/Los_Angeles