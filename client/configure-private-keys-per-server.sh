#!/bin/sh
# Create configuration file in ~/.ssh/config for current user
# to use a different SSH key pair for each host,
# e.g. example.com.rsa to connect to host example.com

echo 'Create config file to use one key per host in ~/.ssh'
cat << EOF | tee ~/.ssh/config
Host *
  # Only use identity files, not any identity loaded in ssh-agent
  IdentitiesOnly yes
  # Define pattern for the names of identity files by host
  IdentityFile %d/.ssh/%h.rsa
  IdentityFile %d/.ssh/%h.dsa
  IdentityFile %d/.ssh/%h.ecdsa
EOF

echo 'Enable config file by setting permissions to u=rw,go='
chmod u=rw,go= ~/.ssh/config
