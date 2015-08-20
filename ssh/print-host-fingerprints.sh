#!/bin/sh
# Print fingerprints of the public keys of the host in all available formats

for filename in $(ls /etc/ssh/ssh_host_*_key.pub)
do
  ssh-keygen -l -f $filename
done
