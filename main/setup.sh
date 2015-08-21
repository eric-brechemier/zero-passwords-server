#!/bin/sh
# Script to setup a server for SSH access and sudo using SSH keys only
# (passwords are disabled both for SSH access and local login/sudo)
# This script runs directly on the server.
#
# Parameters:
#   $1 - string, domain name or IP of the server
#   $2 - string, username of the admin user to create with sudo rights
#
# Pre-Requisite:
# The user running the script must be allowed to access the server as root
# using SSH, and more generally, SSH keys of server administrators shall
# be configured in /root/.ssh/authorized_keys
#
# Project Home:
# https://github.com/eric-brechemier/zero-passwords-server
server="$1"
user="$2"

echo "Server: Configure $server with $user as administrator"

echo "Server: Change to the script's directory"
cd "$(dirname "$0")"



