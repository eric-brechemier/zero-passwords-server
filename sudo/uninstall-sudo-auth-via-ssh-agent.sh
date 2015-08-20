#!/bin/sh
# Uninstall sudo authentication via SSH agent
# previously installed with install-sudo-auth-via-ssh-agent.sh

echo "Remove PAM Profile for pam-ssh-agent-auth"
sudo pam-auth-update --package --remove pam-ssh-agent-auth

echo "Uninstall package pam-ssh-agent-auth, including configuration files"
sudo apt-get --yes purge pam-ssh-agent-auth

