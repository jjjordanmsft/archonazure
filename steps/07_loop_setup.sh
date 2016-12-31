#!/bin/bash

case "$1" in
	desc)
		echo Setup loopback device
		;;
	build)
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
		
		;;
	clean)
		losetup -d $LOOP_DEV
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
