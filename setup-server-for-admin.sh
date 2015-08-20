#!/bin/sh
# Script to setup a server for SSH access and sudo using SSH keys only
# (passwords are disabled both for SSH access and local login/sudo)
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

echo "Change to the script's directory"
cd "$(dirname "$0")"

folder='zero-passwords-server'
archive="$folder.tar.gz"
echo "Package all scripts to run remotely into $archive"
tar -cvzf "$archive" shell ssh sudo main

die()
{
  die_code="$?"
  die_message="$1"
  echo "$die_message"
  exit "$die_code"
}

echo "Copy the $archive to root@$server"
scp "$archive" "root@$server" \
  || die "Failed to upload $archive as root@$server"

echo "Unpack the archive into /root/$directory in $server"
cat << EOF | ssh "root@$server" || die "Failed to run setup.sh on root@$server"
mkdir "$directory"
cd "$directory"
tar -xvzf "../$archive"
./main/setup.sh
EOF
