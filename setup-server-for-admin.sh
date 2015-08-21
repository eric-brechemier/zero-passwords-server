#!/bin/sh
# Script to setup a server for SSH access and sudo using SSH keys only
# (passwords are disabled both for SSH access and local login/sudo)
# This script runs from the local client side, and bootstraps the execution
# on the remote server side.
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

die()
{
  die_code="$?"
  die_message="$1"
  echo "$die_message"
  exit "$die_code"
}

test -n "$server" || die "Client: no server name has been provided."
test -n "$user" || die "Client: no user name has been provided."

echo "Client: Configure $server with $user as administrator"

echo "Client: Change to the script's directory"
cd "$(dirname "$0")"

folder='zero-passwords-server'
archive="$folder.tar.gz"
echo "Client: Package scripts to run remotely and upload them to the server"
tar -cz ssh sudo main | ssh "root@$server" "cat - > $archive" \
  || die "Client: Failed to upload $archive as root@$server"

echo "Client: Unpack the archive into /root/$folder/ in $server"
cat << EOF | ssh -T "root@$server" 'sh'
if test -d "$folder"
then
  rm -rf "$folder"
fi
mkdir "$folder"
cd "$folder"
tar -xzf "../$archive" && rm "../$archive"
EOF

echo "Client: Run /root/$folder/setup.sh on $server"
ssh -T "root@$server" "./$folder/main/setup.sh '$server' '$user'"
