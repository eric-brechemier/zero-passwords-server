#!/bin/sh
# Script to setup a server for SSH access and sudo using SSH keys only
# (passwords are disabled both for SSH access and local login/sudo)
# This script runs directly on the server.
#
# Parameters:
#   $1 - string, username of the admin user to create with sudo rights
#
# Pre-Requisite:
# The user running the script must be allowed to access the server as root
# using SSH, and more generally, SSH keys of server administrators shall
# be configured in /root/.ssh/authorized_keys
#
# Project Home:
# https://github.com/eric-brechemier/zero-passwords-server
user="$1"

die()
{
  die_code="$?"
  die_message="$1"
  echo "$die_message"
  exit "$die_code"
}

test -n "$user" || die "Server: no username given for new user"

echo "Server: Configure server with $user as administrator"

echo "Server: Change to the script's directory"
cd "$(dirname "$0")"

echo "Server: Create new user $user in the group of sudoers"
../sudo/create-sudoer.sh "$user" \
  || die "Server: Failed to create new user $user with sudo rights"

echo "Server: Change to parent directory"
cd ..
folder="$(basename "$(pwd)")"

echo "Server: Copy $folder folder to $user's home directory"
cp -R "../$folder" "/home/$user" \
  || die "Server: Failed to copy $folder to /home/$user"
echo "Server: Grant ownership of /home/$user/$folder to $user"
chown -R "$user:$user" "/home/$user/$folder" \
  || die "Server: Failed to grand ownership of /home/$user/$folder to $user"

echo "Server: Change to /home/$user/ directory"
cd "/home/$user" \
  || die "Server: Failed to change to /home/$user/"

echo "Server: Create .ssh folder for $user"
sudo -H -u "$user" "./$folder/ssh/create-ssh-folder.sh" \
  || die "Server: Failed to create /home/$user/.ssh"

echo "Server: Copy authorized keys of root for the user $user"
cp /root/.ssh/authorized_keys .ssh/ \
  || die "Server: Failed to copy /root/.ssh/authorized_keys for $user"
chown "$user:$user" .ssh/authorized_keys
sudo -H -u "$user" "./$folder/ssh/enable-authorized-keys.sh" \
  || die "Server: Failed to change permissions of authorized_keys for $user"

echo "Server: Change to /root/$folder directory"
cd "/root/$folder" \
  || die "Server: Failed to change to /root/$folder folder"

echo "Server: Download and install PAM module for authentication via SSH"
./sudo/install-sudo-auth-via-ssh-agent.sh \
  || die "Server: Failed to install PAM module for authentication via SSH"

echo "Server: Configure sudo for PAM authentication via SSH"
echo "Server: Preserve SSH authentication socket in sudo environment"
./sudo/import-sudoers-file.sh ./sudo/preserve-ssh-auth-socket.visudo \
  || die "Server: Failed to import sudo config to preserve SSH auth socket"

echo "Server: Disable caching of authentication by sudo"
./sudo/import-sudoers-file.sh ./sudo/disable-auth-caching.visudo \
  || die "Server: Failed to import sudo config to disable auth caching"



