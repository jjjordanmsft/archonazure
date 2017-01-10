#!/bin/bash

source /mnt/opt/provision/settings.sh

genfstab -p /mnt >/mnt/etc/fstab
sed -i -e "s|${LOOP_DEV}p|/dev/sda|g" /mnt/etc/fstab

