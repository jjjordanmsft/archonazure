#!/bin/bash

case "$1" in
	desc)
		echo Install dependencies on builder container
		;;
	build)
		if [ ! -z "${REUSE_DOCKER_IMAGE}" ]; then
			# If not a fresh image, then it might need an update
			$DOCKER_EXEC pacman -Syu --noconfirm || exit $?
		fi
		
		$DOCKER_EXEC pacman -S gptfdisk qemu-headless dosfstools e2fsprogs git --noconfirm
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
