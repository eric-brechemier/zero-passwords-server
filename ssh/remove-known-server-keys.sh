#!/bin/sh
# Delete all SSH keys of given server from known hosts file
#
# Usage: ./remove-known-server-keys.sh SERVER
# with SERVER - string, the domain name or IP used to access the server

SERVER="$1"

echo "Remove SSH keys for $SERVER from known hosts file"
ssh-keygen -R "$SERVER"
