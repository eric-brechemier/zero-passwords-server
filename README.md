# zero-passwords-server

Shell scripts to setup a Ubuntu server
where login and sudo only make use of an SSH key.

Note: there is probably very little specific to Ubuntu in these scripts,
but I have developed them on Ubuntu 12.04 LTS, and the current target
is Ubuntu 14.04 LTS. You may be able to adapt them with limited changes
for different flavors of UNIX systems.

## Usage

1. Create a new server (e.g. a VPS instance)
2. Add public keys of server administrators to /root/.ssh/authorized\_keys.
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

## Step by Step Details of Script Operation

1. package all scripts to run remotely into a single tar.gz archive
2. copy the zero-passwords-server.tar.gz archive to root@example.tld
3. connect as root, unpack the archive, and run the script setup.sh to:
    * reset the SSH keys of the server (safety measure)
    * print fingerprints of the server (for validation at next step)
    * prompt you to confirm that the fingerprints match (to detect MITM)
    * create a new user with given username in the group `sudo`
    * copy authorized\_keys of root for the new user
    * download the PAM module for authentication via SSH agent from SourceForge
    * setup the PAM module for sudo authentication using SSH agent forwarding
    * disable locale forwarding (the server locale is used instead,
      to avoid errors when client's locale is not available on the server)
    * disable password login for SSH (remote login as any user requires keys)
    * disable root login (local login as any user requires keys, in the exact
        same way, including use of authorized_keys configured per user)

## Dependencies

This project uses [the pam\_ssh\_agent\_auth module][PAM_SSH_AGENT_AUTH],
derived from [OpenSSH][OpenSSH]
by [Jamie Beverly and other contributors][CONTRIBUTORS].

[PAM_SSH_AGENT_AUTH]: http://pamsshagentauth.sourceforge.net/
[OpenSSH]: http://www.openssh.com/
[CONTRIBUTORS]: http://sourceforge.net/p/pamsshagentauth/code/HEAD/tree/trunk/CONTRIBUTORS
