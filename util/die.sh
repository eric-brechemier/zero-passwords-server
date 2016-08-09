#!/bin/sh
# Function: die(message)
# Exit the terminal after printing an error message
#
# Parameter:
#   $1 - string, the error message
#
# Standard Error:
#   The error message is printed to standard error.
#
# Status:
#   The status code of the previous command is used as status code for this
#   utility, unless it is 0; die() always returns a non-zero status code.
#
# License:
# http://creativecommons.org/publicdomain/zero/1.0/
#
die()
{
  die_code=$?
  die_message="$1"
  echo "$die_message" 1>&2
  if test $die_code = 0
  then
    exit 1
  else
    exit $die_code
  fi
}
