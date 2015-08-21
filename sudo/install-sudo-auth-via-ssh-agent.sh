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
VERSION='0.10.2'
MODIFIED='2014-03-31'
echo "Configure latest version available: $VERSION ($MODIFIED)"

# Configure behavior of the authentication with regards to the stack
# of available authentication:
# 'sufficient' allows fall-back to password authentication.
# See [3] for other values and details.
AUTH_CONTROL_FIELD='[success=done default=die]'
echo "Configure Authentication Control Field: ${AUTH_CONTROL_FIELD}"

BASE_URL='http://downloads.sourceforge.net/project/pamsshagentauth/'
SOFTWARE="pam_ssh_agent_auth-${VERSION}"
ARCHIVE="${SOFTWARE}.tar.bz2"
DOWNLOAD_PATH="pam_ssh_agent_auth/v${VERSION}/${ARCHIVE}"
DOWNLOAD_URL="${BASE_URL}${DOWNLOAD_PATH}"
BUILD_DIR="/tmp/pamsshagentauth/v${VERSION}"
PAM_PROFILE='/usr/share/pam-configs/pam-ssh-agent-auth'

die()
{
  CODE="$?"
  MESSAGE="$1"
  echo "$MESSAGE"
  exit "$CODE"
}

echo 'Install dependencies of pam_ssh_agent_auth library'
sudo apt-get update
sudo apt-get --yes install \
  libssl-dev libpam0g-dev build-essential checkinstall \
  || die 'Failed to install dependencies of pam_ssh_agent_auth'

echo "Create folder ${BUILD_DIR} for the build"
mkdir --parents "${BUILD_DIR}" \
  || die "Failed to create directory ${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "Download ${SOFTWARE}"
wget --timestamping "${DOWNLOAD_URL}" \
  || die "Failed to download ${DOWNLOAD_URL}"

echo "Extract ${ARCHIVE} to ${SOFTWARE}"
tar --verbose --extract --bzip2 --file ${ARCHIVE} \
  || die "Failed to extract ${ARCHIVE}"
cd ${SOFTWARE}

echo "Configure and build ${SOFTWARE}"
./configure --libexecdir=/lib/security --with-mantype=man \
  || die "Failed to configure ${SOFTWARE}"
make \
  || die "Failed to build ${SOFTWARE}"

echo "Install ${SOFTWARE} as a package in Ubuntu package database"
sudo checkinstall --default \
  || die "Failed to install ${SOFTWARE}"

echo "Add PAM profile to ${PAM_PROFILE}"
umask u=rw,go=r
cat << EOF | sudo tee ${PAM_PROFILE}
Name: PAM SSH Agent Auth
Default: yes
Priority: 448
Auth-Type: Primary
Auth:
  ${AUTH_CONTROL_FIELD} pam_ssh_agent_auth.so file=~/.ssh/authorized_keys
EOF

echo "Enable new PAM Profile ${PAM_PROFILE} by default"
sudo pam-auth-update --package \
  || die "Failed to enable PAM Profile ${PAM_PROFILE}"

die "Installation of ${SOFTWARE} successful"

