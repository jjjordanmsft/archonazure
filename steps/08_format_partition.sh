#!/bin/bash

case "$1" in
	desc)
		echo Setup loopback device
		;;
	build)
		# Format partitions
		$DOCKER_EXEC mkfs.vfat ${LOOP_DEV}p1 || exit $?
		$DOCKER_EXEC mkfs.ext3 ${LOOP_DEV}p2 || exit $?
		
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
