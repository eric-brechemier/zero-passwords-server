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

PID=$$
FILE=$1

EXTENSION='.visudo'
FILENAME="$(basename ${FILE} ${EXTENSION})"
TEMP_DIR="/tmp/import-sudoers-file-${PID}"
TEMP_FILE="${TEMP_DIR}/${FILENAME}"
DESTINATION='/etc/sudoers.d'

cleanup()
{
  echo "Clean-up: delete temporary folder ${TEMP_DIR}"
  sudo rm -rf ${TEMP_DIR}
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

echo "Create temporary copy of ${FILE} in ${TEMP_FILE}"
mkdir ${TEMP_DIR}
cp --preserve=timestamps ${FILE} ${TEMP_FILE} \
  || cleanExit "Failed to copy ${FILE} to ${TEMP_FILE}"

echo 'Change owner/group of temporary file to root'
sudo chown root:root ${TEMP_FILE} \
  || cleanExit 'Failed to change owner'

echo 'Change permissions of temporary file to ug=r,o='
sudo chmod ug=r,o= ${TEMP_FILE} \
  || cleanExit 'Failed to change permissions'

echo "Validate ${TEMP_FILE}"
sudo visudo -s -c -f "${TEMP_FILE}" \
  || cleanExit 'Validation failed: import aborted'

echo "Move ${TEMP_FILE} to ${DESTINATION}"
sudo mv --force ${TEMP_FILE} ${DESTINATION} \
  || cleanExit "Failed to copy sudoers file to ${DESTINATION}"

cleanExit 'Import successful'

