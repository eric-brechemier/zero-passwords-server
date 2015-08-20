#!/bin/sh
# Reset OpenSSH keys of a host, removing previous keys and creating new keys
#
# The host key of a VPS may be duplicated by a snapshot process [1] and it may
# be better to replace the keys anyway when accessing the server for the first
# time: [2] mentions more 'entropy' being available at a later step.
#
# References:
#
# [1] Avoid Duplicate SSH Host Keys
# 2013-07-26, in Digital Ocean Help & Community
#
# [2] Comment on Hacker News
# 2013-07-29, by Andrew Ayer
# https://news.ycombinator.com/item?id=6124872

echo 'Delete previous host keys'
sudo rm -rf /etc/ssh/ssh_host_*

echo 'Generate all missing host keys anew'
sudo ssh-keygen -A
