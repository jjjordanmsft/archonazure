#!/bin/bash

case "$1" in
	desc)
		echo Unmount targets
		;;
	build)
		$DOCKER_EXEC umount ${LOOP_DEV}p2
		losetup -d ${LOOP_DEV}
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
