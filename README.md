# Build scripts for Arch Linux on Azure

This project aims to provide build scripts that generate Arch Linux VHDs capable of running on Azure.  It is currently:

* Broken (see below)
* Unsupported
* Unendorsed. By anybody. Including myself.

But I think it's a good start!  The scripts do not require many external dependencies: only Docker and a handful of utilities you should already have (git, curl, etc).
It does not require Arch Linux, and in fact I'm targetting running this on Ubuntu 16.10.  The scripts can be run as a non-root user, provided you have docker access (though
many of the steps run inside a privileged Docker container).

## Usage

Choose a work directory, this must be on a device that has at least ~4GB free space and is accessible to your user account.  Copy `settings.env.default` to `settings.env` and make any changes there if you see fit (defaults should generally be fine), then:

```
bash build.sh <work directory> [start-step-number [end-step-number]]
```

As you might notice, the script is broken up into steps.  The step numbers are optional; if omitted, the script will proceed from beginning to end, or from where it left off in a previous run.  See further down for actual usage, since there is a bug preventing the VM from being fully provisioned by Azure.

## Inner workings

### The scripts do the following to build an image:
1. Bootstrap an ArchLinux docker image from the latest public drop (see [here](https://github.com/czka/archlinux-docker) for the docker build script)
2. Create and partition a raw, flat image file, and attach it to a loopback device
3. `pacstrap` and configure the new partition from inside the docker container
4. Install `waagent` from my [fork to support Arch](https://github.com/jjjordanmsft/WALinuxAgent), and hack a few things together.
5. Convert to a vhd

### Some things are currently *broken*:
1. The image currently does not find the cdrom/dvd device and `waagent` can't provision the machine (setup the hostname, add the user)
2. SSH sessions inexplicably time out after no data has been sent or received for a short duration.  This does not appear to be due to misconfiguration of `sshd`, but rather some deeper networking issue.
3. Since images are not provisioned by waagent, unless you stop the build and add your username, you won't get access to the machine!  To work around this, the *actual* build steps are currently:

```
bash build.sh <workdir> 1 13
docker exec -it <container name> /bin/bash
arch-chroot /mnt /bin/bash
useradd -m <username>
usermod -aG wheel <username>
passwd <username>
nano /etc/sudoers
# uncomment "%wheel ALL=(ALL) ALL" line
# drop back out to main shell
bash build.sh <workdir>
```

### Some things are also currently *hacked together*:
1. Arch's `dhclient` exits with a failure after obtaining a lease.  This occurs because Azure's DHCP servers return very long lease times and `dhclient` overflows.  Other distributions have had this issue and patched, but upstream ISC dhcp hasn't patched yet.  I submitted a bug report some time ago.  For now, these scripts build and install a patched dhclient to work around the issue.  NOTE: `waagent` *really* wants `dhclient` and not `dhcpcd`, since it reads lease files and writes settings.  To be compatible with `waagent` we probably must stick with ISC.
2. Azure VM extensions written against the old `waagent2.0` agent will fail to install because, on Arch, the default Python is python3.  To work around this, I run the agent in a python2.7 virtualenv so that child processes will find the correct `python` binary in the path.  Extensions *still* don't work after this, but they could conceivably take the changes in my waagent repo to fix this.
