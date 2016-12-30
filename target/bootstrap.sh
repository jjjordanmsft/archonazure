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
pacman -S openssh wget unzip parted python python-setuptools --noconfirm

# WALinuxAgent
export WALINUX_VERSION=2.1.5
wget https://github.com/Azure/WALinuxAgent/archive/v${WALINUX_VERSION}.zip -O /tmp/walinuxagent.zip
unzip /tmp/walinuxagent.zip -d /opt/walinuxagent
cd /opt/walinuxagent/WALinuxAgent-${WALINUX_VERSION}/
python setup.py install --register-service

cat <<-EOF >/etc/systemd/system/walinuxagent.service
[Unit]
Description=Azure Linux Agent
After=network.target
After=sshd.target
[Service]
Type=simple
ExecStartPre=/bin/bash -c "cat /proc/net/route >> /dev/console || true"
ExecStartPre=/bin/bash -c "journalctl -u dhcpcd@eth0 >> /dev/console || true"
ExecStartPre=/bin/bash -c "ip addr >> /dev/console || true"
ExecStart=/usr/bin/python3 /usr/sbin/waagent -daemon
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Setup services
systemctl enable sshd.service
systemctl enable dhcpcd@eth0.service
systemctl enable walinuxagent

# Clean up
pacman -Scc --noconfirm
pacman -Sc --noconfirm
rm -rf ~/.bash_history /var/log/pacman.log
exit 0
