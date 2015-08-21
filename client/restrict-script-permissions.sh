#!/bin/sh
# Only allow scripts in current folder to be executed by owner and group
# Do not allow others to view, modify or execute the files

chmod ug=rwx,o= *.sh
