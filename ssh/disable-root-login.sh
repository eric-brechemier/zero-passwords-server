#!/bin/sh
# Disable SSH login as root
# Reference:
# http://www.howtogeek.com/howto/linux/security-tip-disable-root-ssh-login-on-linux/

echo 'Disable root login for SSH'

# Replace:
#   * any line starting with:
#     o optionally #
#     o followed with 'PermitRootLogin'
#     o followed with a space
#     o optionally followed with any characters
#     o followed with the end of the line
# with:
#   * 'PermitRootLogin no'
sed \
  's/^#\?PermitRootLogin\ .*$/PermitRootLogin\ no/' \
  /etc/ssh/sshd_config \
  | sudo tee /etc/ssh/sshd_config

sudo restart ssh

