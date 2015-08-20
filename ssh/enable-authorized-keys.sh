#!/bin/sh
# Configure permissions on file for keys authorized for SSH login
# as 400 or u=rw,go=

chmod u=rw,go= ~/.ssh/authorized_keys
