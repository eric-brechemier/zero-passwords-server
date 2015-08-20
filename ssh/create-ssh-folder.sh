#!/bin/sh
# Script to create hidden folder .ssh for current user
# with proper permissions (700 or u=rwx,go=)

echo "Create .ssh folder for user $(whoami) in $HOME"
mkdir -p $HOME/.ssh
chmod u=rwx,go= $HOME/.ssh

