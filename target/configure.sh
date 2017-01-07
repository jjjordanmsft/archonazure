#!/bin/bash

source /opt/provision/settings.sh

# This is mostly lifted from Cole Mickens's script, found at
# https://github.com/colemickens/azure-archlinux-packer/blob/master/scripts/configure.sh

# Hostname
echo 'buildingarch' >/etc/hostname

# Timezone
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# Locale
echo "LANG=${LANG}" > /etc/locale.conf
# TODO: Make this more configurable!
sed -i -e 's/\#en\_US/en\_US/g' /etc/locale.gen
locale-gen
echo 'KEYMAP=us' > /etc/vconsole.conf

# Packages
sed -i -e "s/PKGEXT='.pkg.tar.xz'/PKGEXT='.pkg.tar'/g" /etc/makepkg.conf
pacman-db-upgrade
pacman -Syy --noconfirm
pacman -Syu --noconfirm

# HyperV prep
sed -i 's/MODULES=""/MODULES="hv_balloon hv_utils hv_vmbus hv_storvsc hv_netvsc"/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Bootloader
pacman --noconfirm -S grub
grub-install --target=i386-pc --recheck ${LOOP_DEV}
sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="quiet"|GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0 earlyprintk=ttyS0 rootdelay=300"|' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
cat /etc/default/grub

# Dependencies
DEPS=(openssh wget unzip parted python python-setuptools net-tools)
DEPS+=(util-linux sudo shadow sed grep iproute2 dhclient)
DEPS+=(python2 python2-virtualenv python2-setuptools)
pacman --noconfirm -S ${DEPS[@]}

# WALinuxAgent, source should already be found at /opt/walinuxagent
cd /opt/walinuxagent
/usr/bin/python2 setup.py install --prefix="/usr" --optimize=1 --lnx-distro=arch || exit $?

# Create a virtualenv for waagent.  This makes python==python2 so some
# crufty extensions aren't overwhelmed by python3-by-default
virtualenv2 -p /usr/bin/python2 --system-site-packages /usr/lib/waagentenv
sed -i 's|/usr/bin/python|/usr/lib/waagentenv/bin/python|g' /usr/lib/systemd/system/waagent.service
sed -i 's|/usr/bin/env python|/usr/lib/waagentenv/bin/python|g' /usr/bin/waagent

# Setup services
systemctl enable sshd.service
systemctl enable dhclient@eth0.service
systemctl enable waagent.service

# Setup dhclient
cp /opt/provision/dhclient.conf /etc/dhclient.conf

# Clean up
pacman -Scc --noconfirm
pacman -Sc --noconfirm
rm -rf ~/.bash_history /var/log/pacman.log
exit 0
