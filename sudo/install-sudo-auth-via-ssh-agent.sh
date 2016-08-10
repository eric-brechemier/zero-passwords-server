#!/bin/sh
# Install sudo authentication via SSH agent,
# using pam_ssh_agent_auth library:
# http://sourceforge.net/projects/pamsshagentauth/
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

# List of downloads, to find latest version available:
# http://sourceforge.net/projects/pamsshagentauth/files/pam_ssh_agent_auth/
version='0.10.2'
modified='2014-03-31'
echo "Configure latest version available: $version ($modified)"

# Configure behavior of the authentication with regards to the stack
# of available authentication:
# 'sufficient' allows fall-back to password authentication.
# See [3] for other values and details.
authControlField='[success=done default=die]'
echo "Configure Authentication Control Field: ${authControlField}"

baseUrl='http://downloads.sourceforge.net/project/pamsshagentauth/'
software="pam_ssh_agent_auth-${version}"
archive="${software}.tar.bz2"
downloadPath="pam_ssh_agent_auth/v${version}/${archive}"
downloadUrl="${baseUrl}${downloadPath}"
buildDirectory="/usr/local/src/pam-ssh-agent-auth-v${version}"
pamProfile='/usr/share/pam-configs/pam-ssh-agent-auth'

cd "$(dirname "$0")"
. ../util/die.sh

echo 'Install dependencies of pam_ssh_agent_auth library'
sudo apt-get update
sudo apt-get --yes install \
  libssl-dev libpam0g-dev build-essential checkinstall \
  || die 'Failed to install dependencies of pam_ssh_agent_auth'

echo "Create folder ${buildDirectory} for the build"
mkdir --parents "${buildDirectory}" \
  || die "Failed to create directory ${buildDirectory}"
cd "${buildDirectory}"

echo "Download ${software}"
wget --timestamping "${downloadUrl}" \
  || die "Failed to download ${downloadUrl}"

echo "Extract ${archive} to ${software}"
tar --verbose --extract --bzip2 --file ${archive} \
  || die "Failed to extract ${archive}"
cd ${software}

echo "Configure and build ${software}"
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

