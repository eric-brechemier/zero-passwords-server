#!/bin/sh
# Create user with given user name and add it the group of sudoers.
# The password of the new user is disabled.
#
# Parameters:
#   $1 - string, user name of the new user
#   $2 - optional, string, name of the group of sudoers, defaults to 'sudo'
#
# Note:
# If the user exists already, it is left unchanged.
username="$1"
sudoers="${2:-sudo}"

if test -z "$(getent passwd "$username")"
then
  echo "Create user $username with disabled password (default behavior)"
  sudo useradd --create-home --shell /bin/bash --groups "$sudoers" "$username"
else
  echo 'User enz exists already'
fi
