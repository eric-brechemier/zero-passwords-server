#!/bin/sh
# Install sudo authentication via SSH agent,
# using pam_ssh_agent_auth library:
# https://github.com/jbeverly/pam_ssh_agent_auth
#
# References:
#
# [1] sudo auth via ssh-agent
# 2011-12-12, by Michael W Lucas
# http://blather.michaelwlucas.com/archives/1106
#
# [2] Answer to Question: Running 'sudo' over SSH
# 2011-08-21 by Andre de Miranda
# http://serverfault.com/a/303440
#
# [3] PAM.CONF
# man pam.d
#
# [4] pam_ssh_agent_auth website
# http://pamsshagentauth.sourceforge.net/
#
# [5] pam_ssh_agent_auth on SourceForge
# https://sourceforge.net/projects/pamsshagentauth/
#
# [6] pam_ssh_agent_auth on GitHub (latest source)
# https://github.com/jbeverly/pam_ssh_agent_auth
#

cd "$(dirname "$0")"
. ../util/die.sh

# Configure behavior of the authentication with regards to the stack
# of available authentication:
# 'sufficient' allows fall-back to password authentication.
# See [3] for other values and details.
authControlField='[success=done default=die]'
echo "Configure Authentication Control Field: ${authControlField}"

software='pam_ssh_agent_auth'
sourceDirectory="${software}"
buildDirectory='/usr/local/src/pam-ssh-agent-auth'
pamProfile='/usr/share/pam-configs/pam-ssh-agent-auth'

echo "Install dependencies of ${software} library"
sudo apt-get update
sudo apt-get --yes install \
  libssl-dev libpam0g-dev build-essential checkinstall \
  || die 'Failed to install dependencies of pam_ssh_agent_auth'

echo "Delete build directory ${buildDirectory} if it exists already"
rm -rf "${buildDirectory}" \
  || die "Failed to deleted build directory ${buildDirectory}"

echo "Copy sources of ${software} to ${buildDirectory}"
cp -p -R "${sourceDirectory}" "${buildDirectory}" \
  || die "Failed to copy sources from ${sourceDirectory} to ${buildDirectory}"

echo "Configure and build ${software}"
cd "${buildDirectory}"
./configure --libexecdir=/lib/security --with-mantype=man \
  || die "Failed to configure ${software}"
make \
  || die "Failed to build ${software}"

echo "Install ${software} as a package in Ubuntu package database"
sudo checkinstall --default \
  || die "Failed to install ${software}"

echo "Add PAM profile to ${pamProfile}"
umask u=rw,go=r
cat << EOF | sudo tee ${pamProfile}
Name: PAM SSH Agent Auth
Default: yes
Priority: 448
Auth-Type: Primary
Auth:
  ${authControlField} pam_ssh_agent_auth.so file=~/.ssh/authorized_keys
EOF

echo "Enable new PAM Profile ${pamProfile} by default"
sudo pam-auth-update --package \
  || die "Failed to enable PAM Profile ${pamProfile}"

echo "Installation of ${software} successful"

