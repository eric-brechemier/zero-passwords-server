#!/bin/sh
# Delete all SSH keys of given server from known hosts file
#
# Usage: ./remove-known-server-keys.sh server
# with server - string, the domain name or IP used to access the server

server="$1"

echo "Remove SSH keys for $server from known hosts file"
ssh-keygen -R "$server"
