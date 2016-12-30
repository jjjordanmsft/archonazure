#!/bin/bash

case "$1" in
	desc)
		echo Create base filesystems
		;;
	build)
		# Do some math...
		# Boot partition will be 100MB as per standard
		DISK_SIZE=20480
		truncate -s${DISK_SIZE}M rawdisk

		BOOT_START=2048
		BOOT_END=$((${BOOT_START}+(4*1024)))
		ROOT_START=$((${BOOT_END}+1))
		ROOT_END=$(sgdisk -E rawdisk)
		
		# Set up partition table
		$DOCKER_EXEC sgdisk -og /work/rawdisk || exit $?
		$DOCKER_EXEC sgdisk -n 1:$BOOT_START:$BOOT_END -c 1:"biosboot" -t 1:ef00 /work/rawdisk || exit $?
		$DOCKER_EXEC sgdisk -n 2:$ROOT_START:$ROOT_END -c 2:"root" -t 2:8300 /work/rawdisk || exit $?
		$DOCKER_EXEC sgdisk -p /work/rawdisk || exit $?
		
		# Setup loopback devices
		LOOP_DEV=$(losetup -f)
		echo export LOOP_DEV=$LOOP_DEV >$STEP_OUT
		
		losetup -P $LOOP_DEV $WORKDIR/rawdisk || exit $?
		
		# Get the loopback partition devices inside the container
		LOP1MAJ=$(stat -c %t ${LOOP_DEV}p1)
		LOP1MIN=$(stat -c %T ${LOOP_DEV}p1)
		LOP2MAJ=$(stat -c %t ${LOOP_DEV}p2)
		LOP2MIN=$(stat -c %T ${LOOP_DEV}p2)
		$DOCKER_EXEC mknod ${LOOP_DEV}p1 b "0x${LOP1MAJ}" "0x${LOP1MIN}"
		$DOCKER_EXEC mknod ${LOOP_DEV}p2 b "0x${LOP2MAJ}" "0x${LOP2MIN}"
		
		# Format partitions
		$DOCKER_EXEC mkfs.vfat ${LOOP_DEV}p1 || exit $?
		$DOCKER_EXEC mkfs.ext3 ${LOOP_DEV}p2 || exit $?
		
		;;
	clean)
		losetup -d $LOOP_DEV
		rm -rf rawdisk
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
