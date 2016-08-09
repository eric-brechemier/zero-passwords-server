#!/bin/sh
# Disable forwarding of locale from SSH client to server
# The server locale should be used untouched instead.
#
# Reference:
# http://askubuntu.com/a/144448

# Replace:
#   * any line starting with:
#     o 'AcceptEnv'
#     o followed with a single space
#     o followed with 'LANG'
#     o optionally followed with any characters
#     o followed with the end of the line
# with:
#     o '#'
#     o followed with the same line
sed \
  's/^AcceptEnv\ LANG\ .*$/#&/' \
  /etc/ssh/sshd_config \
  | sudo tee /etc/ssh/sshd_config

sudo service ssh restart

