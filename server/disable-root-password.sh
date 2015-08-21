#!/bin/sh
# This script will disable the password of root user,
# thus requiring another form of authentication (via SSH agent)

echo 'Disable password of root user'
passwd -l root
