#!/bin/bash

case "$1" in
	desc)
		echo Install dependencies on builder container
		;;
	build)
		$DOCKER_EXEC pacman -S gptfdisk qemu-headless dosfstools e2fsprogs --noconfirm
		;;
	clean)
		;;
	*)
		echo Should be invoked by build script!
		exit 1
		;;
esac
