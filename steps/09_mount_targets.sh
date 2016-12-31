#!/bin/bash

case "$1" in
	desc)
		echo Mount target partitions
		;;
	build)
		$DOCKER_EXEC mount ${LOOP_DEV}p2 /mnt || exit $?
		;;
	clean)
		$DOCKER_EXEC umount ${LOOP_DEV}p2
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
