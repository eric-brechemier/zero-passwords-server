# zero-passwords-server

Shell scripts to setup a Ubuntu server
where login and sudo only make use of an SSH key.

Note: there is probably very little specific to Ubuntu in these scripts,
but I have developed them on Ubuntu 12.04 LTS, and the current target
is Ubuntu 16.04 LTS. You may be able to adapt them with limited changes
for different flavors of UNIX systems.

## Usage

0. Clone this project recursively (including all its submodules):

```
git clone git@github.com:eric-brechemier/zero-passwords-server.git
git submodule update --init --recursive
```

1. Create a new server (e.g. a VPS instance)
2. Add public keys of server administrators to /root/.ssh/authorized\_keys.
   Hint: use ssh-keygen to create the keys and ssh-copy-id to copy them
   with proper permissions into /root/.ssh/authorized\_keys on the server.
   It is advised to have at least two different keys allowed for safety,
   as this procedure will completely disable password authentication
   on the server, both for SSH authentication and for root login locally.
3. Run the script `setup-server-for-admin.sh example.tld username`
   with `example.tld` replaced with the host name or IP of the server
   and `username` the name of the administrator user that you want to create
   to administer the server using SSH keys for authentication,
   including escalation of privileges for `sudo`.

## Expected Outcome

1. You can now connect with SSH to the server `example.tld` as `username`.
2. When you enable SSH agent forwarding (rarely and cautiously),
   by adding `-A` flag to your SSH command to login as `username`,
   you can now call `sudo` without a password, using your SSH keys instead
   of authentication. Note that if you try to `sudo` while connected to the
   server with agent forwarding disabled (the sane default) you will not be
   prompted for a password and your authentication will be rejected promptly.

You can now run automated scripts to complete the setup of the server
by connecting to the server using the newly created as user, adding
the `-A` flag to enable SSH agent forwarding only when the scripts
need to make use of `sudo`. The scripts will never prompt for a password.

When agent forwarding is enabled, any script running with user privileges
can take advantage of the agent forwarding to escalate to root privileges,
as well as stretch the forwarding to connect to another remote server
configured to authorize the same SSH public key used in the current connection.
To mitigate [this risk][AGENT_FORWARDING_RISK], you can run non privileged
scripts with a different user, and configure distinct SSH key pairs to access
different servers, using `IdentityFile` directive in `~/.ssh/config`.
The example `config` below uses `%h` (remote host name) parameter
in the name of each private key, which allows to connect to `example.com`
using a private key named either `example.com.rsa`, `example.com.dsa`
or `example.com.ecdsa`:

```
Host *
  # Only use identity files, not any identity loaded in ssh-agent
  IdentitiesOnly yes
  # Define pattern for the names of identity files by host
  IdentityFile %d/.ssh/%h.rsa
  IdentityFile %d/.ssh/%h.dsa
  IdentityFile %d/.ssh/%h.ecdsa
```

[AGENT_FORWARDING_RISK]:
http://unixwiz.net/techtips/ssh-agent-forwarding.html#sec

Note that on Mac OSX and other systems, the SSH agent starts with no identity
loaded, thus no identity may be forwarded. You can load your key in the agent
by running `ssh-add`, without any argument to load default keys, or with the
path to a specific key. The agent will remember these keys until shutdown or
`ssh-add` is called with the flag `-d` to forget a specific key, or the default
keys when no argument is provided, or the flag `-D` to forget all keys.
The keys may also be stored in Keychain, by using the flag `-K`, which will
allow the agent to remember them across reboots.

## Step by Step Details of Script Operation

1. Upload scripts to run remotely to the server:
    * package the scripts into a compressed archive
    * copy this archive to /root on the server
    * extract the archive into /root/zero-passwords/server
2. Reset the SSH keys of the server (safety measure)
    * generate new SSH keys for the SSH server, on the server itself
    * print fingerprints of the server (for verification when prompted)
    * remove the previous SSH server keys from local list of known hosts
    * prompt you to confirm that the fingerprints match (to detect MITM)
3. Run the script /root/zero-passwords-server/server/setup.sh to:
    * create a new user with given username in the group `sudo`
    * copy authorized\_keys of root for the new user
    * download the PAM module for authentication via SSH agent from SourceForge
    * setup the PAM module for sudo authentication using SSH agent forwarding
    * disable locale forwarding (the server locale is used instead,
      to avoid errors when client's locale is not available on the server)
    * disable password login for SSH (remote login as any user requires keys)
    * disable root login for SSH (for extra safety)
    * disable root password, even locally (to require authentication via SSH)

## Dependencies

This project uses [the pam\_ssh\_agent\_auth module][PAM_SSH_AGENT_AUTH],
derived from [OpenSSH][OpenSSH]
by [Jamie Beverly and other contributors][CONTRIBUTORS].

[PAM_SSH_AGENT_AUTH]: http://pamsshagentauth.sourceforge.net/
[OpenSSH]: http://www.openssh.com/
[CONTRIBUTORS]: http://sourceforge.net/p/pamsshagentauth/code/HEAD/tree/trunk/CONTRIBUTORS
