#!/bin/bash

case "$1" in
	desc)
		echo Run pacstrap
		;;
	build)
		$DOCKER_EXEC pacstrap -d /mnt base || exit $?
		;;
	clean)
		$DOCKER_EXEC rm -rf '/mnt/*'
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
