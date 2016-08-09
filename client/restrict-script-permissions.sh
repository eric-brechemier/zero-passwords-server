#!/bin/sh
# Only allow scripts in current folder to be executed by owner and group;
# only allow the user to modify the scripts.
# Do not allow others to view, modify or execute the files

chmod u=rwx,g=rx,o= *.sh
