#!/bin/bash

case "$1" in
	desc)
		echo Create image file and partitions
		;;
	build)
		# Do some math...
		# Boot partition will be 100MB as per standard
		DISK_SIZE=20480
		truncate -s${DISK_SIZE}M rawdisk

		BOOT_START=2048
		BOOT_END=$((${BOOT_START}+(4*1024))) # 2 MB
		ROOT_START=$((${BOOT_END}+1))
		
		# Set up partition table
		$DOCKER_EXEC sgdisk -og /work/rawdisk || exit $?
		ROOT_END=$(sgdisk -E $WORKDIR/rawdisk)
		$DOCKER_EXEC sgdisk -n 1:$BOOT_START:$BOOT_END -c 1:"biosboot" -t 1:ef02 /work/rawdisk || exit $?
		$DOCKER_EXEC sgdisk -n 2:$ROOT_START:$ROOT_END -c 2:"root" -t 2:8300 /work/rawdisk || exit $?
		$DOCKER_EXEC sgdisk -p /work/rawdisk || exit $?
		
		;;
	clean)
		rm -rf rawdisk
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
