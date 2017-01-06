#!/bin/bash

case "$1" in
	desc)
		echo Create image file and partitions
		;;
	build)
		# Do some math...
		truncate -s${DISK_SIZE:-20480}M rawdisk

		BOOT_END=$((${BOOT_START:-2048}+(4*1024))) # 2 MB
		ROOT_START=$((${BOOT_END}+1))
		
		# Set up partition table
		$DOCKER_EXEC sgdisk -og /work/rawdisk || exit $?
		ROOT_END=$($DOCKER_EXEC sgdisk -E /work/rawdisk)
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
