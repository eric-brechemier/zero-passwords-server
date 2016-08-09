#!/bin/sh
# Script to validate and copy a sudoers file to /etc/sudoers.d/,
# removing file extension '.visudo', setting owner/group to root
# and setting file permissions to ug=r,o=
#
# Usage:
# import-sudoers-file.sh <filename>
# where filename is the path to a sudoers file
#
# References:
# man sudo
# /etc/sudoers.d/README

pid=$$
file=$1

extension='.visudo'
filename="$(basename ${file} ${extension})"
temporaryDirectory="/tmp/import-sudoers-file-${pid}"
temporaryFile="${temporaryDirectory}/${filename}"
destination='/etc/sudoers.d'

cleanup()
{
  echo "Clean-up: delete temporary folder ${temporaryDirectory}"
  sudo rm -rf ${temporaryDirectory}
}

cleanExit()
{
  # Print message given as argument and exit script with current status code,
  # after calling cleanup() function.
  #
  # Usage:
  # dosomething || cleanExit "Failed to do something"

  CODE="$?"
  MESSAGE="$1"
  cleanup
  echo "$MESSAGE"
  exit "$CODE"
}

echo "Create temporary copy of ${file} in ${temporaryFile}"
mkdir ${temporaryDirectory}
cp --preserve=timestamps ${file} ${temporaryFile} \
  || cleanExit "Failed to copy ${file} to ${temporaryFile}"

echo 'Change owner/group of temporary file to root'
sudo chown root:root ${temporaryFile} \
  || cleanExit 'Failed to change owner'

echo 'Change permissions of temporary file to ug=r,o='
sudo chmod ug=r,o= ${temporaryFile} \
  || cleanExit 'Failed to change permissions'

echo "Validate ${temporaryFile}"
sudo visudo -s -c -f "${temporaryFile}" \
  || cleanExit 'Validation failed: import aborted'

echo "Move ${temporaryFile} to ${destination}"
sudo mv --force ${temporaryFile} ${destination} \
  || cleanExit "Failed to copy sudoers file to ${destination}"

cleanExit 'Import successful'

