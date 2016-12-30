#!/bin/bash

case "$1" in
	desc)
		echo Run pacstrap
		;;
	build)
		$DOCKER_EXEC pacstrap -d /work/mnt base || exit $?
		;;
	clean)
		rm -rf /work/mnt/*
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
