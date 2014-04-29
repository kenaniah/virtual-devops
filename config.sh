#!/bin/bash

# Defines config options used by other scripts

# Static IP address of the puppet server (will be set in /etc/hosts)
PUPPET_IP=192.241.234.84

# Hosts that puppet will automatically sign certs for
PUPPET_AUTOSIGN=*

# MySQL password for dashboard@localhost
PUPPET_DASHBOARD_MYSQL_PASSWORD="dEd8vN87eZZEhae" 

# Timezone of the server
TZ=America/Los_Angeles
