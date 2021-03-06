#!/bin/sh
# Disallow use of passwords for SSH login (only allow private key login)
# Reference:
# https://help.ubuntu.com/community/SSH/OpenSSH/Configuring

cd "$(dirname "$0")"
. ../util/die.sh

echo 'Disable password login for SSH'

# Replace:
#   * any line starting with:
#     o optionally #
#     o followed with 'PasswordAuthentication'
#     o followed with a space
#     o optionally followed with any characters
#     o followed with the end of the line
# with:
#   * 'PasswordAuthentication no'
sed \
  's/^#\?PasswordAuthentication\ .*$/PasswordAuthentication\ no/' \
  /etc/ssh/sshd_config \
| sudo tee /etc/ssh/sshd_config.new \
|| die 'Failed to write updated sshd_config'

sudo mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config

sudo service ssh restart

